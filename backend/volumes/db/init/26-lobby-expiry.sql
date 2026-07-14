-- Framed lobby inactivity expiry (issue #70). Idempotent.
--
-- Two mechanisms, both gated on status = 'lobby' and both keyed off
-- players.last_seen (10-schema.sql), bumped by the heartbeat() RPC below
-- while a client sits in the lobby screen:
--   1. tick_lobby_expiry: wipe a lobby nobody's touched in an hour, a
--      shorter, separate expiry than tick_cleanup()'s 24h GDPR backstop
--      (25-cleanup.sql), which stays unchanged for active/dispersing/
--      finished games and for a lobby that just never gets caught here.
--   2. tick_inactive_lobby_players: drop a single player who's gone quiet
--      while the rest of the lobby stays active, on their own shorter
--      timeout, through remove_lobby_player (13-lobby.sql) — the exact
--      effects a live leave_lobby call produces.

-- heartbeat(game_id): lobby liveness ping. Silent no-op if the caller
-- isn't a member — the client fires this on a timer without checking
-- preconditions itself, same as a missed one just means the ping was
-- late, not an error worth surfacing.
create or replace function heartbeat(game_id uuid) returns void
language sql security definer set search_path = '' as $$
  update public.players set last_seen = now()
  where game_id = heartbeat.game_id and auth_uid = auth.uid();
$$;

revoke execute on function heartbeat(uuid) from public, anon;
grant execute on function heartbeat(uuid) to authenticated;

-- Step: drop individually inactive players from a lobby others are still
-- keeping alive. 15 minutes of heartbeat silence — meaningfully shorter
-- than tick_lobby_expiry's hour below, since one quiet player shouldn't
-- need to wait as long as an entirely abandoned lobby does.
create or replace function tick_inactive_lobby_players(g public.games) returns void
language plpgsql set search_path = '' as $$
declare p public.players%rowtype;
begin
  if g.status <> 'lobby' then return; end if;

  for p in
    select * from public.players
    where game_id = g.id and last_seen < now() - interval '15 minutes'
  loop
    perform public.remove_lobby_player(g, p.id);
  end loop;
end $$;

revoke execute on function tick_inactive_lobby_players(public.games)
  from public, anon, authenticated;

-- Step: wipe a lobby nobody's touched in an hour. "Activity" is the most
-- recent heartbeat across every player still seated, falling back to the
-- game's own created_at if that's null (a lobby with zero players mid-tick,
-- e.g. right after tick_inactive_lobby_players above just emptied it).
create or replace function tick_lobby_expiry(g public.games) returns void
language plpgsql set search_path = '' as $$
declare last_activity timestamptz;
begin
  if g.status <> 'lobby' then return; end if;

  select coalesce(max(last_seen), g.created_at) into last_activity
  from public.players where game_id = g.id;

  if last_activity < now() - interval '1 hour' then
    perform public.wipe_game(g.id, true);
  end if;
end $$;

revoke execute on function tick_lobby_expiry(public.games)
  from public, anon, authenticated;
