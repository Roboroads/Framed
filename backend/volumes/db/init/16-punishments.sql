-- Framed geofence enforcement, punishment timers, and kill_player (issue
-- #13). Idempotent.
--
-- tick_punishments replaces #12's tick_locations (see 15-locations.sql,
-- which now only keeps the shared is_stale() helper): this is the single
-- place that computes combined rule-break reasons (stale + outside the
-- geofence) and owns rule_break_since, so one warning event carries every
-- reason a player is currently breaking instead of two competing emitters.
drop function if exists tick_locations(public.games);

-- Outside if beyond geofence_radius_m from geofence_center. A player with no
-- location yet isn't "outside" — that's staleness's problem, not this rule's.
create or replace function is_outside_geofence(p public.players, g public.games) returns boolean
language sql immutable as $$
  select p.last_location is not null
    and not public.st_dwithin(g.geofence_center, p.last_location, g.geofence_radius_m)
$$;

-- Proactive edge nudge (#61): still inside, but within 5% of the radius of
-- leaving. A separate, earlier signal than is_outside_geofence — that one
-- only flips once the player has actually left.
create or replace function is_near_geofence_edge(p public.players, g public.games) returns boolean
language sql immutable as $$
  select p.last_location is not null
    and public.st_dwithin(g.geofence_center, p.last_location, g.geofence_radius_m)
    and not public.st_dwithin(g.geofence_center, p.last_location, g.geofence_radius_m * 0.95)
$$;

-- #61: tracks the in/out transition of is_near_geofence_edge, same shape as
-- outside_geofence_since — null except while currently near the edge.
alter table public.players add column if not exists near_geofence_edge_since timestamptz;

-- kill_player(...): the only way a circle-death happens. Shared by this
-- tick's MIA punishment below and #20's vote-resolution kill.
create or replace function kill_player(
  player_id uuid, cause public.death_cause, killer uuid, photo_path text
) returns void language plpgsql security definer set search_path = '' as $$
declare
  victim public.players%rowtype;
  g public.games%rowtype;
  assassin_id uuid;
  new_target public.players%rowtype;
  killer_name text;
  void_frame_id uuid;
begin
  select * into victim from public.players where id = kill_player.player_id for update;
  if not found then raise exception using message = 'not_found'; end if;
  if victim.status <> 'alive' then return; end if; -- already dead: no-op, not an error

  select * into g from public.games where id = victim.game_id;

  update public.players set
    status = 'dead', death_cause = cause, died_at = now(),
    killed_by = killer, death_photo_path = photo_path
  where id = victim.id;

  -- the dead can't kill: void any frame the victim had in flight
  select id into void_frame_id from public.frames
    where frames.assassin_id = victim.id and status in ('held', 'pending');
  if void_frame_id is not null then
    perform public.cancel_frame(void_frame_id);
  end if;

  -- relink the circle: victim's assassin inherits victim's target
  select id into assassin_id from public.players
    where game_id = victim.game_id and target_id = victim.id;
  if assassin_id is not null then
    update public.players set target_id = victim.target_id where id = assassin_id;
    if victim.target_id is not null then
      select * into new_target from public.players where id = victim.target_id;
      perform public.emit('player:' || assassin_id, 'target_assigned',
        jsonb_build_object('target_id', new_target.id,
                            'name_ciphertext', new_target.name_ciphertext,
                            'selfie_path', new_target.selfie_path));
      perform public.send_pulse_to(assassin_id);
    end if;
  end if;

  if killer is not null then
    select name_ciphertext into killer_name from public.players where id = killer;
  end if;

  perform public.emit('player:' || victim.id, 'you_died',
    jsonb_build_object(
      'cause', cause,
      'killer_name_ciphertext', killer_name,
      'photo_path', photo_path,
      'survived_seconds', extract(epoch from now() - coalesce(g.active_at, victim.joined_at))::int
    ));
end $$;

revoke execute on function kill_player(uuid, public.death_cause, uuid, text)
  from public, anon, authenticated;

-- Stub until #16 (compass pulse engine) lands — that issue replaces this
-- with the real immediate personal-snapshot pulse on target reassignment.
create or replace function send_pulse_to(player_id uuid) returns void
language plpgsql set search_path = '' as $$
begin
end $$;

-- Step: geofence + staleness rule-breaks, combined into one warning per
-- player, plus the soft/hard punishment timers.
create or replace function tick_punishments(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  p public.players%rowtype;
  outside boolean;
  near_edge boolean;
  reasons text[];
  assassin_id uuid;
begin
  if g.status not in ('dispersing', 'active') then return; end if;

  for p in select * from public.players where game_id = g.id and status = 'alive' loop
    outside := public.is_outside_geofence(p, g);

    if outside and p.outside_geofence_since is null then
      p.outside_geofence_since := now();
      update public.players set outside_geofence_since = now() where id = p.id;
    elsif not outside and p.outside_geofence_since is not null then
      p.outside_geofence_since := null;
      update public.players set outside_geofence_since = null where id = p.id;
    end if;

    -- geofence_proximity (#61): a heads-up before is_outside_geofence would
    -- ever flip, so a player can step back in before the warning below (and
    -- its punishment clock) ever starts. One event per transition, same
    -- shape as warning below. is_near_geofence_edge already requires "not
    -- outside", so crossing the boundary clears this on its own — no
    -- explicit handoff to the reactive warning needed.
    near_edge := public.is_near_geofence_edge(p, g);
    if near_edge and p.near_geofence_edge_since is null then
      p.near_geofence_edge_since := now();
      update public.players set near_geofence_edge_since = now() where id = p.id;
      perform public.emit('player:' || p.id, 'geofence_proximity',
        jsonb_build_object('active', true));
    elsif not near_edge and p.near_geofence_edge_since is not null then
      p.near_geofence_edge_since := null;
      update public.players set near_geofence_edge_since = null where id = p.id;
      perform public.emit('player:' || p.id, 'geofence_proximity',
        jsonb_build_object('active', false));
    end if;

    -- warning: one combined event per active/inactive transition, not every
    -- tick while a player stays broken — reasons carries whichever apply.
    reasons := array[]::text[];
    if public.is_stale(p) then reasons := array_append(reasons, 'stale'); end if;
    if outside then reasons := array_append(reasons, 'geofence'); end if;

    if array_length(reasons, 1) > 0 then
      if p.rule_break_since is null then
        p.rule_break_since := now();
        update public.players set rule_break_since = now() where id = p.id;
      end if;
      perform public.emit('player:' || p.id, 'warning',
        jsonb_build_object(
          'active', true,
          'reasons', to_jsonb(reasons),
          'hard_deadline', p.rule_break_since + (g.hard_punishment_minutes || ' minutes')::interval
        ));
    elsif p.rule_break_since is not null then
      p.rule_break_since := null;
      update public.players set rule_break_since = null where id = p.id;
      perform public.emit('player:' || p.id, 'warning', jsonb_build_object('active', false));
    end if;

    -- soft punishment: assassin sees the exact location every tick, once
    -- outside long enough. Nothing new for the stale-only case — the
    -- assassin's compass already points at the target's last-known spot.
    if outside and now() - p.outside_geofence_since
       > (g.soft_punishment_minutes || ' minutes')::interval then
      select id into assassin_id from public.players
        where game_id = g.id and target_id = p.id;
      if assassin_id is not null and p.last_location is not null then
        perform public.emit('player:' || assassin_id, 'target_location',
          jsonb_build_object('lat', public.st_y(p.last_location::public.geometry),
                              'lng', public.st_x(p.last_location::public.geometry)));
      end if;
    end if;

    -- hard punishment: MIA death, either reason, past the combined timer.
    if p.rule_break_since is not null
       and now() - p.rule_break_since > (g.hard_punishment_minutes || ' minutes')::interval then
      perform public.kill_player(p.id, 'mia', null, null);
    end if;
  end loop;
end $$;

revoke execute on function tick_punishments(public.games),
  is_outside_geofence(public.players, public.games),
  is_near_geofence_edge(public.players, public.games), send_pulse_to(uuid)
  from public, anon, authenticated;
