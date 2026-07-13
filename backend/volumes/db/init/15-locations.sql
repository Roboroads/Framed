-- Framed location pipeline: ingestion, movement counters, staleness (issue
-- #12). Idempotent.
--
-- submit_location(game_id, lat, lng): alive player only, dispersing/active
-- games only (location updates and geofence enforcement start at game start,
-- not after dispersal — IDEA.md "Game rules"). Updates the movement counters
-- from the delta against the previous last_location, then overwrites it.
-- There is deliberately no location history table anywhere in this schema —
-- the overwrite is the privacy design, not an optimization.
create or replace function submit_location(
  game_id uuid, lat double precision, lng double precision
) returns void language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
  g public.games%rowtype;
  new_point public.geography;
  moved_m double precision;
begin
  select * into me from public.players p
    where p.game_id = submit_location.game_id and p.auth_uid = auth.uid() for update;
  if not found then raise exception using message = 'not_found'; end if;
  if me.status <> 'alive' then raise exception using message = 'not_alive'; end if;

  select * into g from public.games where id = submit_location.game_id;
  if g.status not in ('dispersing', 'active') then
    raise exception using message = 'wrong_status';
  end if;

  new_point := public.st_setsrid(public.st_makepoint(lng, lat), 4326)::public.geography;

  if me.last_location is not null then
    moved_m := public.st_distance(me.last_location, new_point);
    update public.players set distance_moved_m = distance_moved_m + moved_m where id = me.id;
    if moved_m < 5 then
      update public.players
        set still_seconds = still_seconds + round(extract(epoch from now() - me.last_location_at))::int
        where id = me.id;
    end if;
  end if;

  update public.players set last_location = new_point, last_location_at = now()
    where id = me.id;
end $$;

revoke execute on function submit_location(uuid, double precision, double precision)
  from public, anon;
grant execute on function submit_location(uuid, double precision, double precision)
  to authenticated;

-- Shared staleness check (3 missed 30s updates) — reused by the compass pulse
-- engine (#16) and, later, the geofence/punishment tick (#13).
create or replace function is_stale(p public.players) returns boolean
language sql immutable as $$
  select p.last_location_at is null or now() - p.last_location_at > interval '90 seconds'
$$;

-- Step: stale-location warnings only — punishment escalation to MIA death is
-- #13's job, reading the same is_stale()/rule_break_since this sets.
--
-- rule_break_since is shared with the (not yet built) geofence rule-break —
-- #13 will need to merge reasons instead of blindly overwriting this column;
-- for now staleness is the only source so simple set/clear is correct.
--
-- Only emits on the active/inactive transition, not every tick while a
-- player stays stale — one event per state change, not per tick.
create or replace function tick_locations(g public.games) returns void
language plpgsql set search_path = '' as $$
declare
  p public.players%rowtype;
  since timestamptz;
begin
  if g.status not in ('dispersing', 'active') then return; end if;

  for p in select * from public.players where game_id = g.id and status = 'alive' loop
    if public.is_stale(p) and p.rule_break_since is null then
      since := coalesce(p.last_location_at, g.started_at, g.active_at, now())
        + interval '90 seconds';
      update public.players set rule_break_since = since where id = p.id;
      perform public.emit('player:' || p.id, 'warning',
        jsonb_build_object(
          'active', true,
          'reasons', jsonb_build_array('stale'),
          'hard_deadline', since + (g.hard_punishment_minutes || ' minutes')::interval
        ));
    elsif not public.is_stale(p) and p.rule_break_since is not null then
      update public.players set rule_break_since = null where id = p.id;
      perform public.emit('player:' || p.id, 'warning', jsonb_build_object('active', false));
    end if;
  end loop;
end $$;

revoke execute on function tick_locations(public.games) from public, anon, authenticated;
