-- Framed win detection, stats, kill chain, and replay (issue #25).
-- Idempotent. tick_win_check(g) is game_tick()'s last step — it runs after
-- deaths (tick_punishments, tick_vote_timeouts), so a kill that ends the
-- game is caught the same tick it happens.

alter table public.players add column if not exists left_at timestamptz;

-- finish_game: shared by every way a game can end (tick_win_check and
-- tick_min_players_check below) — marks the game finished,
-- builds the stats/kill-chain payload, and fans out game_finished. The
-- update is its own resolution lock ("where status = 'active'"), same idiom
-- as resolve_frame (20-votes.sql): two end conditions can both go true in
-- the same tick (both callers read the same stale pre-tick snapshot, see
-- 14-start-tick.sql's header comment), so whichever runs first wins and the
-- second is a silent no-op instead of double-finishing the game.
create or replace function finish_game(g public.games, winner_id uuid) returns void
language plpgsql set search_path = '' as $$
declare
  stats jsonb;
  kill_chain jsonb;
begin
  update public.games set
    status = 'finished', finished_at = now(), winner_player_id = finish_game.winner_id
    where id = g.id and status = 'active';
  if not found then return; end if;

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

  perform public.emit('game:' || g.id, 'game_finished',
    jsonb_build_object('winner_id', finish_game.winner_id, 'stats', stats, 'kill_chain', kill_chain));
  -- game:{id} is one broadcast for everyone; push is per-player (#27), so
  -- this is the one enqueue site that fans out to the whole roster.
  perform public.enqueue_push(p.id, 'game_finished')
  from public.players p where p.game_id = g.id;
end $$;

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

  perform public.finish_game(g, winner.id);
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

-- leave_active_game(game_id): the caller's own row, dead only — IDEA.md
-- "Game rules"' no-mid-game-quit binds the living only (#77). Unlike
-- leave_lobby/leave_finished_game this happens mid-game: the row stays
-- (still counted in stats/kill_chain), just marked left_at and dropped
-- from the judge pool (notify_judges/cast_vote, 19-frames.sql/20-votes.sql)
-- and the eligible count tick_min_players_check reads below.
create or replace function leave_active_game(game_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  me public.players%rowtype;
begin
  select * into g from public.games where id = leave_active_game.game_id;
  if not found then raise exception using message = 'not_found'; end if;
  if g.status <> 'active' then raise exception using message = 'wrong_status'; end if;

  select * into me from public.players p
    where p.game_id = leave_active_game.game_id and p.auth_uid = auth.uid()
    for update;
  if not found then raise exception using message = 'not_member'; end if;
  if me.status <> 'dead' then raise exception using message = 'must_be_dead'; end if;

  update public.players set left_at = now() where id = me.id and left_at is null;
end $$;

-- tick_min_players_check: once dead players can leave mid-game
-- (leave_active_game above), the judge pool (notify_judges/cast_vote —
-- every non-left player but the assassin and target) can run dry before
-- anyone's vote is guaranteed a verdict. Below 3 players still in the
-- roster (left_at is null, alive or dead — the eligible pool) there's no
-- way to guarantee a judge for whoever's left, so the game ends right
-- there: the current frame-count leader wins, same "tolerates a dead
-- winner" precedent as most_frames mode. Independent of tick_win_check's
-- Final Duel (2 alive) handling above, which still resolves normally as
-- long as a judge is present — this is only the fallback for when leaving
-- has thinned the roster too far for that to hold.
create or replace function tick_min_players_check(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  eligible_count int;
  winner public.players%rowtype;
begin
  if g.status <> 'active' then return; end if;

  select count(*) into eligible_count from public.players
    where game_id = g.id and left_at is null;
  if eligible_count >= 3 then return; end if;

  select * into winner from public.players
    where game_id = g.id and left_at is null
    order by kills desc, died_at desc
    limit 1;

  perform public.finish_game(g, winner.id);
end $$;

revoke execute on function
  finish_game(public.games, uuid), tick_win_check(public.games), tick_min_players_check(public.games)
  from public, anon, authenticated;
revoke execute on function
  replay_game(uuid, text, jsonb), rejoin_replay(uuid, text, text),
  leave_finished_game(uuid), leave_active_game(uuid)
  from public, anon;
grant execute on function
  replay_game(uuid, text, jsonb), rejoin_replay(uuid, text, text),
  leave_finished_game(uuid), leave_active_game(uuid)
  to authenticated;
