-- Framed lobby lifecycle RPCs: create_game, update_settings, join_game,
-- leave_lobby, set_selfie (issue #5). Idempotent.
--
-- All functions are security definer with search_path = '' — callers are
-- anonymous-auth users (role authenticated), identified by auth.uid().
-- Errors use stable message codes the app matches on: bad_settings, not_host,
-- wrong_status, invalid_token, name_taken, already_joined, not_member,
-- not_found.

-- Current settings of a game as one jsonb (also the settings_changed payload)
create or replace function framed_settings_json(g public.games) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'mode', g.mode,
    'disperse_minutes', g.disperse_minutes,
    'soft_punishment_minutes', g.soft_punishment_minutes,
    'hard_punishment_minutes', g.hard_punishment_minutes,
    'compass_update_interval_minutes', g.compass_update_interval_minutes,
    'compass_view_seconds', g.compass_view_seconds,
    'vote_timeout_minutes', g.vote_timeout_minutes,
    'frame_cooldown_minutes', g.frame_cooldown_minutes,
    'geofence_radius_m', g.geofence_radius_m,
    'geofence_lat', public.st_y(g.geofence_center::public.geometry),
    'geofence_lng', public.st_x(g.geofence_center::public.geometry)
  )
$$;

-- Apply the known settings keys from s to the game. Unknown keys are ignored;
-- identity fields (name_*, push_token, platform) ride in the same jsonb on
-- create_game and are simply not settings.
create or replace function framed_apply_settings(gid uuid, s jsonb)
returns void language plpgsql set search_path = '' as $$
begin
  -- sanity on host input: intervals and radius positive, coordinates on Earth
  -- case, not "and": SQL where-clauses don't short-circuit, and the jsonb
  -- also carries non-numeric values (name_ciphertext on create_game)
  perform 1 from jsonb_each_text(s) as kv(k, v)
    where case
      when k in ('disperse_minutes', 'soft_punishment_minutes',
                 'hard_punishment_minutes', 'compass_update_interval_minutes',
                 'compass_view_seconds', 'vote_timeout_minutes',
                 'frame_cooldown_minutes', 'geofence_radius_m')
        then v::int < 1
      else false
    end;
  if found then raise exception using message = 'bad_settings'; end if;
  if abs(coalesce((s ->> 'geofence_lat')::float8, 0)) > 90
     or abs(coalesce((s ->> 'geofence_lng')::float8, 0)) > 180 then
    raise exception using message = 'bad_settings';
  end if;

  update public.games g set
    mode = coalesce((s ->> 'mode')::public.game_mode, g.mode),
    disperse_minutes = coalesce((s ->> 'disperse_minutes')::int, g.disperse_minutes),
    soft_punishment_minutes = coalesce((s ->> 'soft_punishment_minutes')::int, g.soft_punishment_minutes),
    hard_punishment_minutes = coalesce((s ->> 'hard_punishment_minutes')::int, g.hard_punishment_minutes),
    compass_update_interval_minutes = coalesce((s ->> 'compass_update_interval_minutes')::int, g.compass_update_interval_minutes),
    compass_view_seconds = coalesce((s ->> 'compass_view_seconds')::int, g.compass_view_seconds),
    vote_timeout_minutes = coalesce((s ->> 'vote_timeout_minutes')::int, g.vote_timeout_minutes),
    frame_cooldown_minutes = coalesce((s ->> 'frame_cooldown_minutes')::int, g.frame_cooldown_minutes),
    geofence_radius_m = coalesce((s ->> 'geofence_radius_m')::int, g.geofence_radius_m),
    geofence_center = case
      when s ? 'geofence_lat' and s ? 'geofence_lng' then
        public.st_setsrid(public.st_makepoint(
          (s ->> 'geofence_lng')::float8, (s ->> 'geofence_lat')::float8
        ), 4326)::public.geography
      else g.geofence_center
    end
  where g.id = gid;
exception
  when invalid_text_representation or datatype_mismatch then
    -- unparseable number or enum value ('mode': 'nonsense')
    raise exception using message = 'bad_settings';
end $$;

-- create_game(settings) -> {game_id, join_token}
-- The host is a regular player: their row is created here from the identity
-- fields in the jsonb. The join token is the only way into the game.
create or replace function create_game(settings jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  gid uuid;
  pid uuid;
  tok text;
begin
  if coalesce(settings ->> 'name_ciphertext', '') = ''
     or coalesce(settings ->> 'name_hmac', '') = ''
     or length(settings ->> 'name_ciphertext') > 2048 then
    raise exception using message = 'bad_settings';
  end if;

  tok := translate(encode(extensions.gen_random_bytes(16), 'base64'), '+/=', '-_');
  insert into public.games (join_token) values (tok) returning id into gid;
  begin
    insert into public.players
      (game_id, auth_uid, name_ciphertext, name_hmac, push_token, platform, is_host)
    values
      (gid, auth.uid(), settings ->> 'name_ciphertext', settings ->> 'name_hmac',
       settings ->> 'push_token', settings ->> 'platform', true)
    returning id into pid;
  exception
    when check_violation or not_null_violation then
      raise exception using message = 'bad_settings';
  end;
  update public.games set host_player_id = pid where id = gid;
  perform public.framed_apply_settings(gid, settings);

  return jsonb_build_object('game_id', gid, 'join_token', tok);
end $$;

-- update_settings(game_id, settings): host only, lobby only
create or replace function update_settings(game_id uuid, settings jsonb)
returns void language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
begin
  select * into g from public.games where id = game_id for update;
  if not found then raise exception using message = 'not_found'; end if;
  if not exists (select 1 from public.players p
                 where p.id = g.host_player_id and p.auth_uid = auth.uid()) then
    raise exception using message = 'not_host';
  end if;
  if g.status <> 'lobby' then raise exception using message = 'wrong_status'; end if;

  perform public.framed_apply_settings(g.id, settings);
  select * into g from public.games where id = game_id;
  perform public.emit('game:' || g.id, 'settings_changed',
    jsonb_build_object('settings', public.framed_settings_json(g)));
end $$;

-- join_game(join_token, ...) -> {game_id, player_id}
-- Token resolution happens only here; the same invalid_token comes back
-- whether the token never existed or its game already started (tokens are
-- nulled at start).
--
-- A retry by the same auth_uid (app crashed or was closed before reaching
-- the lobby, player rescans the same QR) hands back their existing seat
-- instead of erroring — this is the lobby half of reconnect (#54); the
-- ingame half is get_my_state (21-reconnect.sql).
create or replace function join_game(
  join_token text, name_ciphertext text, name_hmac text,
  push_token text default null, platform text default null
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  pid uuid;
  vconstraint text;
  rejoining boolean := false;
begin
  if coalesce(name_ciphertext, '') = '' or coalesce(name_hmac, '') = ''
     or length(name_ciphertext) > 2048 then
    raise exception using message = 'bad_settings';
  end if;

  select * into g from public.games ga
    where ga.join_token = join_game.join_token for update;
  if not found then raise exception using message = 'invalid_token'; end if;
  if g.status <> 'lobby' then raise exception using message = 'wrong_status'; end if;

  begin
    insert into public.players
      (game_id, auth_uid, name_ciphertext, name_hmac, push_token, platform)
    values
      (g.id, auth.uid(), join_game.name_ciphertext, join_game.name_hmac,
       join_game.push_token, join_game.platform)
    returning id into pid;
  exception
    when unique_violation then
      get stacked diagnostics vconstraint = constraint_name;
      if vconstraint = 'players_game_id_auth_uid_key' then
        select id into pid from public.players
          where game_id = g.id and auth_uid = auth.uid();
        rejoining := true;
      elsif vconstraint = 'players_game_id_name_hmac_key' then
        raise exception using message = 'name_taken';
      else
        raise;
      end if;
    when check_violation then
      raise exception using message = 'bad_settings';
  end;

  if not rejoining then
    perform public.emit('game:' || g.id, 'player_joined',
      jsonb_build_object('player_id', pid, 'name_ciphertext', join_game.name_ciphertext));
  end if;
  return jsonb_build_object('game_id', g.id, 'player_id', pid);
end $$;

-- leave_lobby(game_id): remove own player row (and selfie); transfer host to
-- the earliest joined_at; delete the game when the last player leaves.
create or replace function leave_lobby(game_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  me public.players%rowtype;
  heir uuid;
begin
  select * into g from public.games where id = game_id for update;
  if not found then raise exception using message = 'not_found'; end if;
  if g.status <> 'lobby' then raise exception using message = 'wrong_status'; end if;

  select * into me from public.players p
    where p.game_id = leave_lobby.game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;

  -- the row delete unlinks the blob; physical file cleanup is the cleanup
  -- issue's job (the bytes are AES-GCM ciphertext either way)
  perform set_config('storage.allow_delete_query', 'true', true);
  delete from storage.objects
    where bucket_id = 'selfies' and name = g.id || '/' || me.id;
  perform set_config('storage.allow_delete_query', 'false', true);

  delete from public.players where id = me.id;

  if not exists (select 1 from public.players p where p.game_id = g.id) then
    delete from public.games where id = g.id;
    return;
  end if;

  if g.host_player_id = me.id then
    select p.id into heir from public.players p
      where p.game_id = g.id order by p.joined_at, p.id limit 1;
    update public.games set host_player_id = heir where id = g.id;
    update public.players set is_host = true where id = heir;
    perform public.emit('game:' || g.id, 'host_changed',
      jsonb_build_object('player_id', heir));
  end if;

  perform public.emit('game:' || g.id, 'player_left',
    jsonb_build_object('player_id', me.id));
end $$;

-- set_selfie(game_id, path): client uploaded the encrypted selfie to the
-- canonical path (storage policy in 11-policies.sql); this records it and
-- marks the player ready.
create or replace function set_selfie(game_id uuid, path text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
begin
  select * into me from public.players p
    where p.game_id = set_selfie.game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;
  if path <> me.game_id || '/' || me.id then
    raise exception using message = 'bad_settings';
  end if;
  if not exists (select 1 from storage.objects o
                 where o.bucket_id = 'selfies' and o.name = path) then
    raise exception using message = 'not_found';
  end if;
  update public.players set selfie_path = path where id = me.id;
  perform public.emit('game:' || me.game_id, 'player_ready',
    jsonb_build_object('player_id', me.id));
end $$;

-- Only signed-in players call these; strip the default-ACL grants otherwise
revoke execute on function
  framed_settings_json(public.games), framed_apply_settings(uuid, jsonb)
  from public, anon, authenticated;
revoke execute on function
  create_game(jsonb), update_settings(uuid, jsonb),
  join_game(text, text, text, text, text), leave_lobby(uuid), set_selfie(uuid, text)
  from public, anon;
grant execute on function
  create_game(jsonb), update_settings(uuid, jsonb),
  join_game(text, text, text, text, text), leave_lobby(uuid), set_selfie(uuid, text)
  to authenticated;
