-- Framed vote resolution: majority math, timeouts, verdict effects (issue
-- #20). Idempotent. Builds on #19 (submit_frame, notify_judges) and #13
-- (kill_player).

-- cancel_frame: the shared void path. Only a *pending* frame ever got a
-- frame_to_judge fan-out, so only a pending frame has judges to tell.
create or replace function cancel_frame(p_frame_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  f public.frames%rowtype;
  j public.players%rowtype;
begin
  select * into f from public.frames where id = p_frame_id for update;
  if not found or f.status not in ('held', 'pending') then return; end if;

  if f.status = 'pending' then
    for j in select * from public.players
      where game_id = f.game_id and id not in (f.assassin_id, f.target_id)
    loop
      perform public.emit('player:' || j.id, 'frame_cancelled',
        jsonb_build_object('frame_id', f.id));
    end loop;
  end if;

  update public.frames set status = 'void' where id = f.id;
end $$;

-- release_held_frame: called after a verdict fails (the target survives).
-- Releases the held frame (if any) whose assassin is p_target_id — that
-- frame was waiting on p_target_id's own verdict, which just resolved in
-- their favor, so it's free to be judged. Fresh clock, fresh fan-out.
create or replace function release_held_frame(p_target_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  held public.frames%rowtype;
  g public.games%rowtype;
begin
  select * into held from public.frames
    where assassin_id = p_target_id and status = 'held';
  if not found then return; end if;

  select * into g from public.games where id = held.game_id;
  update public.frames set
    status = 'pending', pending_since = now(),
    resolves_at = now() + (g.vote_timeout_minutes || ' minutes')::interval
  where id = held.id;
  perform public.notify_judges(held.id);
end $$;

-- resolve_frame: shared by cast_vote's early-majority path and the
-- timeout tick below. "where status = 'pending'" makes the update itself
-- the resolution lock — a frame already resolved by the other path is a
-- silent no-op here. p_reason (#86) is only meaningful when !p_passed —
-- 'rejected' for an actual majority no, 'timeout' when the vote deadline
-- passed without one (tie or nobody judged in time) — so the assassin's
-- cooldown screen can say why instead of just sitting there unexplained.
drop function if exists resolve_frame(uuid, boolean);
create or replace function resolve_frame(
  p_frame_id uuid, p_passed boolean, p_reason text default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  f public.frames%rowtype;
  g public.games%rowtype;
  cooldown_until timestamptz;
begin
  update public.frames set
    status = case when p_passed then 'passed' else 'failed' end::public.frame_status
    where id = p_frame_id and status = 'pending'
    returning * into f;
  if not found then return; end if;

  select * into g from public.games where id = f.game_id;

  if p_passed then
    -- kill_player relinks the circle, voids the victim's own frame (via
    -- cancel_frame) and emits you_died.
    perform public.kill_player(f.target_id, 'framed', f.assassin_id, f.photo_path);
    update public.players set kills = kills + 1 where id = f.assassin_id;
    perform public.send_pulse_to(f.assassin_id);
    perform public.emit('player:' || f.assassin_id, 'frame_verdict',
      jsonb_build_object('passed', true));
    perform public.enqueue_push(f.assassin_id, 'frame_verdict');
  else
    cooldown_until := now() + (g.frame_cooldown_minutes || ' minutes')::interval;
    update public.players set frame_cooldown_until = cooldown_until where id = f.assassin_id;
    perform public.emit('player:' || f.assassin_id, 'frame_verdict',
      jsonb_build_object(
        'passed', false, 'cooldown_until', cooldown_until, 'reason', p_reason));
    perform public.enqueue_push(f.assassin_id, 'frame_verdict');
    -- the target survives: whatever held frame was waiting on their own
    -- verdict is now free to be judged
    perform public.release_held_frame(f.target_id);
  end if;
end $$;

-- cast_vote(frame_id, vote): judges only — a player of the frame's game,
-- not the assassin, not the target, alive or dead. One vote per judge (pk
-- on frame_votes); a repeat vote or a vote on an already-resolved frame is
-- a silent no-op, not an error — the modal may still be open somewhere.
create or replace function cast_vote(frame_id uuid, vote boolean) returns void
language plpgsql security definer set search_path = '' as $$
#variable_conflict use_column
declare
  f public.frames%rowtype;
  me public.players%rowtype;
  yes_count integer;
  no_count integer;
begin
  select * into f from public.frames where id = cast_vote.frame_id for update;
  if not found then raise exception using message = 'not_found'; end if;

  select * into me from public.players p
    where p.game_id = f.game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;
  if me.id = f.assassin_id or me.id = f.target_id then
    raise exception using message = 'not_a_judge';
  end if;
  -- #77: a judge who's since left the game (left_at) can't cast a fresh
  -- vote — notify_judges already excludes them from the fan-out, this
  -- closes the same door for a vote cast without that push/broadcast.
  if me.left_at is not null then
    raise exception using message = 'not_a_judge';
  end if;
  if f.status <> 'pending' then return; end if;

  insert into public.frame_votes (frame_id, judge_id, vote)
  values (f.id, me.id, cast_vote.vote)
  on conflict (frame_id, judge_id) do nothing;

  select count(*) filter (where fv.vote), count(*) filter (where not fv.vote)
    into yes_count, no_count
    from public.frame_votes fv where fv.frame_id = f.id;

  -- mathematical majority of all J judges (frozen at creation), not just
  -- votes cast so far: yes can win outright, or become unable to.
  if yes_count > f.judge_count / 2.0 then
    perform public.resolve_frame(f.id, true);
  elsif no_count >= f.judge_count / 2.0 then
    perform public.resolve_frame(f.id, false, 'rejected');
  end if;
end $$;

-- Timeout step: pending frames past their deadline resolve on votes
-- actually cast — majority yes passes, tie or zero votes fails. This is
-- deliberately not the same math as cast_vote's early path: cast_vote
-- reasons about all J judges, this reasons about who actually showed up.
create or replace function tick_vote_timeouts(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  f public.frames%rowtype;
  yes_count integer;
  no_count integer;
begin
  if g.status <> 'active' then return; end if;

  for f in select * from public.frames
    where game_id = g.id and status = 'pending' and resolves_at <= now()
  loop
    select count(*) filter (where vote), count(*) filter (where not vote)
      into yes_count, no_count
      from public.frame_votes where frame_id = f.id;
    perform public.resolve_frame(f.id, yes_count > no_count, 'timeout');
  end loop;
end $$;

revoke execute on function
  cancel_frame(uuid), release_held_frame(uuid), resolve_frame(uuid, boolean, text),
  tick_vote_timeouts(public.games)
  from public, anon, authenticated;
revoke execute on function cast_vote(uuid, boolean) from public, anon;
grant execute on function cast_vote(uuid, boolean) to authenticated;
