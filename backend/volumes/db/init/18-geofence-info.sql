-- Framed geofence read-back for the ingame client (issue #18). Idempotent.
--
-- geofence_center is stored as PostGIS geography, which PostgREST can't
-- return as plain lat/lng through a normal select — this RPC unpacks it.
-- Members only (mirrors games_member_select in 11-policies.sql).
create or replace function get_my_geofence(game_id uuid)
returns table (lat double precision, lng double precision, radius_m int)
language sql stable security definer set search_path = '' as $$
  select
    public.st_y(g.geofence_center::public.geometry),
    public.st_x(g.geofence_center::public.geometry),
    g.geofence_radius_m
  from public.games g
  where g.id = get_my_geofence.game_id
    and public.framed_my_player(g.id) is not null
$$;

revoke execute on function get_my_geofence(uuid) from public, anon;
grant execute on function get_my_geofence(uuid) to authenticated;
