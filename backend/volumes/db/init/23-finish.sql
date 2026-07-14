-- Framed win detection, stats, kill chain, and replay (issue #25).
-- Idempotent. tick_win_check(g) is game_tick()'s last step — it runs after
-- deaths (tick_punishments, tick_vote_timeouts), so a kill that ends the
-- game is caught the same tick it happens.

alter table public.players add column if not exists left_at timestamptz;

-- tick_win_check: active games with <= 1 alive player are over. The winner
-- ordering handles both modes and the zero-alive MIA-cascade case in one
-- pass:
--   1. last_man_standing: the (at most one) alive player sorts first.
--   2. most_frames: highest kills sorts first, regardless of mode key 1
--      (a dead top-fragger beats the survivor).
--   3. died_at desc: Postgres sorts NULL (still alive) first under DESC by
--      default, so within a most_frames kills-tie the survivor wins; among
--      the dead (or in last_man_standing's zero-alive case) it's most
--      recent death first, i.e. whoever outlasted the rest.
create or replace function tick_win_check(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  alive_count int;
  winner public.players%rowtype;
  stats jsonb;
  kill_chain jsonb;
begin
  if g.status <> 'active' then return; end if;

  select count(*) into alive_count from public.players
    where game_id = g.id and status = 'alive';
  if alive_count > 1 then return; end if;

  select * into winner from public.players
    where game_id = g.id
    order by
      case when g.mode = 'last_man_standing' then (status = 'alive')::int else 0 end desc,
      case when g.mode = 'most_frames' then kills else 0 end desc,
      died_at desc
    limit 1;

  select jsonb_build_object(
      'players', coalesce(jsonb_agg(jsonb_build_object(
        'player_id', p.id,
        'kills', p.kills,
        'distance_moved_m', p.distance_moved_m,
        'still_seconds', p.still_seconds,
        'survived_seconds', extract(epoch from
          coalesce(p.died_at, now()) - coalesce(g.active_at, p.joined_at))::int
      )), '[]'::jsonb),
      'total_distance_moved_m', coalesce(sum(p.distance_moved_m), 0),
      'duration_seconds', extract(epoch from now() - coalesce(g.active_at, g.started_at))::int
    ) into stats
    from public.players p where p.game_id = g.id;

  select coalesce(jsonb_agg(jsonb_build_object(
      'victim_id', p.id, 'killer_id', p.killed_by,
      'cause', p.death_cause, 'died_at', p.died_at
    ) order by p.died_at), '[]'::jsonb) into kill_chain
    from public.players p where p.game_id = g.id and p.status = 'dead';

  update public.games set
    status = 'finished', finished_at = now(), winner_player_id = winner.id
    where id = g.id;

  perform public.emit('game:' || g.id, 'game_finished',
    jsonb_build_object('winner_id', winner.id, 'stats', stats, 'kill_chain', kill_chain));
end $$;

-- replay_game(game_id, key_ciphertext, settings) -> new_game_id. Host only,
-- finished only. The new game carries the old settings (framed_settings_json)
-- with the caller's overrides merged on top, same "known keys only" contract
-- as update_settings.
create or replace function replay_game(
  game_id uuid, key_ciphertext text, settings jsonb default '{}'::jsonb
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  host_auth_uid uuid;
  new_gid uuid;
  new_host uuid;
  tok text;
begin
  select * into g from public.games where id = replay_game.game_id for update;
  if not found then raise exception using message = 'not_found'; end if;
  select auth_uid into host_auth_uid from public.players where id = g.host_player_id;
  if host_auth_uid is distinct from auth.uid() then
    raise exception using message = 'not_host';
  end if;
  if g.status <> 'finished' then raise exception using message = 'wrong_status'; end if;

  tok := translate(encode(extensions.gen_random_bytes(16), 'base64'), '+/=', '-_');
  insert into public.games (join_token, replay_of, replay_key_ciphertext)
    values (tok, g.id, key_ciphertext)
    returning id into new_gid;
  perform public.framed_apply_settings(new_gid,
    public.framed_settings_json(g) || coalesce(replay_game.settings, '{}'::jsonb));

  -- Rows reserved, content refreshed on arrival: selfie_path stays null
  -- (not ready) until each client's rejoin_replay re-uploads under the new
  -- key. ponytail: no storage-object copy here — nothing reads the old
  -- blob before a client refreshes it, so there's nothing worth copying.
  insert into public.players (game_id, auth_uid, name_ciphertext, name_hmac, push_token, platform)
  select new_gid, p.auth_uid, p.name_ciphertext, p.name_hmac, p.push_token, p.platform
  from public.players p
  where p.game_id = g.id and p.left_at is null;

  select id into new_host from public.players p
    where p.game_id = new_gid and p.auth_uid = host_auth_uid;
  update public.players set is_host = true where id = new_host;
  update public.games set host_player_id = new_host where id = new_gid;

  perform public.emit('game:' || g.id, 'replay_started',
    jsonb_build_object('new_game_id', new_gid, 'key_ciphertext', key_ciphertext, 'join_token', tok));

  return new_gid;
end $$;

-- rejoin_replay(game_id, name_ciphertext, name_hmac): the caller's own
-- reserved row only. name_* are re-encrypted under the new key (same
-- plaintext name — HMAC differs because the key does); the selfie must
-- already be re-uploaded to the canonical path (same convention as
-- set_selfie) before this call, since that's what marks the row ready.
create or replace function rejoin_replay(game_id uuid, name_ciphertext text, name_hmac text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
  path text;
begin
  select * into me from public.players p
    where p.game_id = rejoin_replay.game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;
  if coalesce(rejoin_replay.name_ciphertext, '') = ''
     or coalesce(rejoin_replay.name_hmac, '') = ''
     or length(rejoin_replay.name_ciphertext) > 2048 then
    raise exception using message = 'bad_settings';
  end if;

  path := me.game_id || '/' || me.id;
  if not exists (select 1 from storage.objects o
                 where o.bucket_id = 'selfies' and o.name = path) then
    raise exception using message = 'not_found';
  end if;

  begin
    update public.players set
      name_ciphertext = rejoin_replay.name_ciphertext,
      name_hmac = rejoin_replay.name_hmac,
      selfie_path = path
    where id = me.id;
  exception
    when unique_violation then raise exception using message = 'name_taken';
  end;

  perform public.emit('game:' || me.game_id, 'player_ready',
    jsonb_build_object('player_id', me.id));
end $$;

-- leave_finished_game(game_id): soft-leave, input for #29's cleanup (wipe
-- once everyone's left or 24h, whichever first). Unlike leave_lobby this
-- never deletes the row — stats/kill_chain still reference it.
create or replace function leave_finished_game(game_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
begin
  select * into me from public.players p
    where p.game_id = leave_finished_game.game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;
  update public.players set left_at = now() where id = me.id;
end $$;

revoke execute on function tick_win_check(public.games) from public, anon, authenticated;
revoke execute on function
  replay_game(uuid, text, jsonb), rejoin_replay(uuid, text, text), leave_finished_game(uuid)
  from public, anon;
grant execute on function
  replay_game(uuid, text, jsonb), rejoin_replay(uuid, text, text), leave_finished_game(uuid)
  to authenticated;
