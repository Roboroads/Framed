-- Framed cleanup and retention: game wipe, 24h autoclean, aggregate stats
-- (issue #29). Idempotent. tick_cleanup() runs once per game_tick(), after
-- the per-game step loop — it needs to see finished games too, which that
-- loop's `where status <> 'finished'` deliberately excludes.

-- games.replay_of (10-schema.sql) had no ON DELETE behavior — the old game
-- in a replay chain must be wipeable once its players move on, without the
-- new game's still-live row blocking it via this FK. The new game's own
-- data is already complete and independent by then (replay_game copies it
-- at replay time, #25); it just loses the "replayed from" breadcrumb.
alter table games drop constraint if exists games_replay_of_fkey;
alter table games add constraint games_replay_of_fkey
  foreign key (replay_of) references games (id) on delete set null;

-- wipe_game(game_id, autocleaned): the only place a game's rows and
-- storage objects are deleted. Appends one anonymous aggregate_stats row
-- first (no ids, no names, no locations — safe to keep forever), deletes
-- both storage prefixes, then the game row itself: players, frames,
-- frame_votes, and chat_messages all cascade from it (10-schema.sql),
-- taking last locations, counters, and push tokens with the players.
-- Asserts nothing dangles afterward — a partial wipe must fail loudly,
-- not report success.
create or replace function wipe_game(p_game_id uuid, p_autocleaned boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  player_count int;
  duration_minutes int;
  remaining int;
begin
  select * into g from public.games where id = p_game_id for update;
  if not found then return; end if; -- already gone: nothing to do

  select count(*) into player_count from public.players where game_id = g.id;
  duration_minutes := coalesce(
    extract(epoch from
      coalesce(g.finished_at, now()) - coalesce(g.active_at, g.created_at)
    )::int / 60,
    0
  );

  insert into public.aggregate_stats
    (finished_on, player_count, duration_minutes, autocleaned)
    values (current_date, player_count, duration_minutes, p_autocleaned);

  perform set_config('storage.allow_delete_query', 'true', true);
  delete from storage.objects
    where bucket_id = 'selfies' and name like g.id || '/%';
  delete from storage.objects
    where bucket_id = 'frames' and name like g.id || '/%';
  perform set_config('storage.allow_delete_query', 'false', true);

  delete from public.games where id = g.id;

  select count(*) into remaining from (
    select 1 from public.players where game_id = p_game_id
    union all select 1 from public.frames where game_id = p_game_id
    union all select 1 from public.chat_messages where game_id = p_game_id
    union all select 1 from storage.objects
      where bucket_id = 'selfies' and name like p_game_id || '/%'
    union all select 1 from storage.objects
      where bucket_id = 'frames' and name like p_game_id || '/%'
  ) as leftovers;
  if remaining > 0 then
    raise exception using message = 'wipe_incomplete';
  end if;
end $$;

revoke execute on function wipe_game(uuid, boolean) from public, anon, authenticated;

-- tick_cleanup: two wipe triggers, each its own pass so one game's
-- eligibility for one trigger doesn't shadow the other's query plan.
--   1. Finished, every player has left (leave_finished_game, #25) — a
--      replay chain wipes the same way once its players move on; the new
--      game already has its own copied rows and its own 24h clock by then
--      (replay_game, #25), so there's nothing left to lose.
--   2. Any game past 24h old (created_at), any status — the IDEA.md
--      "Privacy & GDPR" auto-clean backstop for a lobby or active game
--      nobody ever finished or left.
create or replace function tick_cleanup() returns void
language plpgsql security definer set search_path = '' as $$
declare g public.games%rowtype;
begin
  for g in
    select * from public.games ga
    where ga.status = 'finished'
      and exists (select 1 from public.players p where p.game_id = ga.id)
      and not exists (
        select 1 from public.players p
        where p.game_id = ga.id and p.left_at is null
      )
    for update skip locked
  loop
    perform public.wipe_game(g.id, false);
  end loop;

  for g in
    select * from public.games ga
    where ga.created_at < now() - interval '24 hours'
    for update skip locked
  loop
    perform public.wipe_game(g.id, true);
  end loop;
end $$;

revoke execute on function tick_cleanup() from public, anon, authenticated;

-- Not per-game data, but stale anon auth users (one per device per install)
-- accumulate regardless of games ever played — a weekly sweep instead of a
-- tick step, since there's no per-tick urgency.
select cron.schedule('cleanup-stale-anon-users', '0 3 * * 0', $$
  delete from auth.users where is_anonymous = true and created_at < now() - interval '30 days'
$$);
