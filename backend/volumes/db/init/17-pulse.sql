-- Framed compass pulse engine (issue #16). Idempotent.
--
-- send_pulse_to(player_id) replaces #13's stub: computes a bearing +
-- distance snapshot from the player's last_location to their target's
-- last_location and emits it. Used here per global pulse, and by
-- kill_player (#13)/cast_vote (#20) for the fresh snapshot an assassin
-- gets on inheriting a target.
--
-- next_pulse_override (#73) lets tick_pulses below hand over the
-- following pulse's time explicitly: mid-loop, g.next_pulse_at in the
-- table is still this round's (about-to-fire) value, only advanced once
-- after every player's send. The other two callers pass nothing, so the
-- client just gets the table's current value — correct for them since
-- they're not the call advancing it.
create or replace function send_pulse_to(
  player_id uuid, next_pulse_override timestamptz default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
  target public.players%rowtype;
  g public.games%rowtype;
  bearing double precision;
begin
  select * into me from public.players where id = send_pulse_to.player_id;
  if not found or me.target_id is null or me.last_location is null then return; end if;

  select * into target from public.players where id = me.target_id;
  if target.last_location is null then return; end if;

  select * into g from public.games where id = me.game_id;

  bearing := degrees(public.st_azimuth(me.last_location, target.last_location));
  if bearing < 0 then bearing := bearing + 360; end if;

  perform public.emit('player:' || me.id, 'compass_pulse',
    jsonb_build_object(
      'bearing_deg', bearing,
      'distance_m', public.st_distance(me.last_location, target.last_location),
      'expires_at', now() + (g.compass_view_seconds || ' seconds')::interval,
      'next_pulse_at', coalesce(next_pulse_override, g.next_pulse_at)
    ));
  perform public.enqueue_push(me.id, 'compass_pulse');
end $$;

revoke execute on function send_pulse_to(uuid, timestamptz) from public, anon, authenticated;

-- Step: the global pulse. Fires once every compass_update_interval_minutes
-- for active games, then reschedules from the scheduled time (not now())
-- so the cadence doesn't drift by tick latency.
create or replace function tick_pulses(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  p public.players%rowtype;
  next_at timestamptz;
begin
  if g.status <> 'active' or g.next_pulse_at is null or now() < g.next_pulse_at then
    return;
  end if;

  next_at := g.next_pulse_at + (g.compass_update_interval_minutes || ' minutes')::interval;

  for p in select * from public.players where game_id = g.id and status = 'alive' loop
    -- rule-breaking (stale or outside the geofence) and lazy judges get
    -- nothing this pulse — IDEA.md "Game rules".
    continue when public.is_stale(p);
    continue when public.is_outside_geofence(p, g);
    continue when exists (
      select 1 from public.frames f
      where f.game_id = g.id and f.status = 'pending'
        and f.assassin_id <> p.id and f.target_id <> p.id
        and not exists (
          select 1 from public.frame_votes fv
          where fv.frame_id = f.id and fv.judge_id = p.id
        )
    );

    perform public.send_pulse_to(p.id, next_at);
  end loop;

  update public.games set next_pulse_at = next_at where id = g.id;
end $$;

revoke execute on function tick_pulses(public.games) from public, anon, authenticated;
