-- Framed game start + server tick skeleton (issue #6). Idempotent.
--
-- start_game shuffles the circle and begins dispersal. game_tick() is the
-- 30-second cron job that drives everything else; it is one function per
-- non-finished game calling clearly named step functions. This issue adds
-- step 1 only (end of dispersal). Later issues append their own
-- tick_*(game) step and one call to it in game_tick() — the frame itself
-- should not need to change.
--
-- Step functions read the games row passed in from game_tick()'s per-tick
-- snapshot; a step that changes fields a later step in the SAME tick
-- depends on must re-select before reading them. tick_pulses reading a
-- stale status/next_pulse_at right after tick_end_dispersal activates the
-- game is the one exception: it just costs the first pulse one extra tick
-- (~30s) against a multi-minute interval, so it's left alone.

create extension if not exists pg_cron with schema cron;

-- start_game(game_id): host only, lobby only, needs 3+ ready (selfie_path
-- set) players. Shuffles ready players into one cycle — random order, each
-- player's target is the next, last wraps to first. Players without a
-- selfie are left out of the circle entirely (no target, not targeted);
-- the pre-join flow is expected to make this the empty set in practice.
create or replace function start_game(game_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  ids uuid[];
  n int;
  started timestamptz := now();
begin
  select * into g from public.games where id = start_game.game_id for update;
  if not found then raise exception using message = 'not_found'; end if;
  if not exists (select 1 from public.players p
                 where p.id = g.host_player_id and p.auth_uid = auth.uid()) then
    raise exception using message = 'not_host';
  end if;
  if g.status <> 'lobby' then raise exception using message = 'wrong_status'; end if;

  select array_agg(p.id order by random()) into ids
  from public.players p where p.game_id = g.id and p.selfie_path is not null;
  n := coalesce(array_length(ids, 1), 0);
  if n < 3 then raise exception using message = 'too_few_players'; end if;

  for i in 1..n loop
    update public.players set target_id = ids[(i % n) + 1] where id = ids[i];
  end loop;

  update public.games set status = 'dispersing', started_at = started, join_token = null
    where id = g.id;

  -- g is the pre-update snapshot (started_at was still null there) — use
  -- the `started` variable captured above, not g.started_at
  perform public.emit('game:' || g.id, 'dispersal_started',
    jsonb_build_object('ends_at', started + (g.disperse_minutes || ' minutes')::interval));
end $$;

-- Step 1: dispersal ends -> active, first pulse scheduled, targets revealed.
create or replace function tick_end_dispersal(g public.games) returns void
language plpgsql set search_path = '' as $$
declare next_pulse timestamptz;
begin
  if g.status <> 'dispersing' or g.started_at is null
     or now() < g.started_at + (g.disperse_minutes || ' minutes')::interval then
    return;
  end if;

  next_pulse := now() + (g.compass_update_interval_minutes || ' minutes')::interval;
  update public.games set status = 'active', active_at = now(), next_pulse_at = next_pulse
    where id = g.id;

  perform public.emit('player:' || p.id, 'target_assigned',
    jsonb_build_object('target_id', t.id, 'name_ciphertext', t.name_ciphertext,
                        'selfie_path', t.selfie_path))
  from public.players p join public.players t on t.id = p.target_id
  where p.game_id = g.id and p.status = 'alive';

  perform public.enqueue_push(p.id, 'target_assigned')
  from public.players p
  where p.game_id = g.id and p.status = 'alive' and p.target_id is not null;
end $$;

create or replace function game_tick() returns void
language plpgsql security definer set search_path = '' as $$
declare g public.games%rowtype;
begin
  -- skip locked: if pg_cron ever overlaps two ticks (a run past 30s), the
  -- second invocation skips games the first is already holding, instead of
  -- both reading the same pre-update snapshot and double-emitting
  for g in select * from public.games where status <> 'finished' for update skip locked loop
    perform public.tick_end_dispersal(g);
    perform public.tick_punishments(g);
    perform public.tick_pulses(g);
    perform public.tick_vote_timeouts(g);
    perform public.tick_win_check(g);
    -- later steps: tick_cleanup(g)
  end loop;
end $$;

select cron.schedule('game-tick', '30 seconds', 'select game_tick()');

revoke execute on function start_game(uuid) from public, anon;
grant execute on function start_game(uuid) to authenticated;
revoke execute on function tick_end_dispersal(public.games), game_tick()
  from public, anon, authenticated;
