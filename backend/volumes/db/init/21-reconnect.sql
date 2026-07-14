-- Framed reconnect: get_my_state (issue #53, #54).
--
-- The client's only view of an active game is the one-shot player:{id}
-- realtime broadcasts (dispersal_started, target_assigned, you_died,
-- warning). If a client's channel goes stale after one was sent (#53), or
-- the app cold-starts back into a game already in progress (#54), there's
-- no way to recover without a REST fallback. This is that fallback:
-- whatever the client would have learned from the last broadcast it
-- should have received, recomputed fresh from current server state.
--
-- game_status is the routing signal (lobby vs. ingame — the lobby screen
-- already rebuilds its own state from a plain REST fetch, this only needs
-- to tell a cold-start resume which screen to land on). event/payload is
-- the phase catch-up (dispersing/target/dead), in the exact shape of the
-- matching broadcast (12-realtime.sql's catalogue) so the client can
-- decode it with the same GameEvent.fromBroadcast it already uses for the
-- live channel, no second parser needed. event is null when there's
-- nothing further to report (still in the lobby, or active with a target
-- not assigned yet — the latter shouldn't happen in practice since
-- start_game assigns every ready player a target before dispersal begins,
-- but the client should tolerate it rather than assume).
--
-- active_warning (#74) is separate from event/payload rather than another
-- case of it: a rule-break can be in progress during either dispersing or
-- active, alongside whichever phase event already applies, so it can't
-- share that single slot. Always present (never null) for an alive
-- player, current truth either way — active:false for "not breaking any
-- rule right now" lets a stale client-side warning modal clear itself on
-- resync, not just pick up a fresher hard_deadline. Investigated as a
-- root-cause candidate for the reported "countdown reaches 00:00 and
-- sits there" bug: tick_punishments's own kill logic checked out fine
-- against a manufactured dispersal-phase repro, so this closes the one
-- concrete gap actually found — no catch-up existed for an in-progress
-- warning, unlike every other event type — rather than a proven fix for
-- the exact reported session.
--
-- Idempotent, side-effect-free, cheap enough to call on every IngameBloc
-- init in addition to listening for the live broadcast, not just on
-- cold-start resume.
create or replace function get_my_state(p_game_id uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
  g public.games%rowtype;
  t public.players%rowtype;
  killer_name text;
  active_warning jsonb;
begin
  select * into g from public.games where id = p_game_id;
  if not found then raise exception using message = 'not_found'; end if;

  select * into me from public.players p
    where p.game_id = p_game_id and p.auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;

  active_warning := case
    when me.status = 'alive' and me.rule_break_since is not null then
      jsonb_build_object(
        'active', true,
        'reasons', to_jsonb(array_remove(array[
          case when public.is_stale(me) then 'stale' end,
          case when public.is_outside_geofence(me, g) then 'geofence' end
        ], null)),
        'hard_deadline', me.rule_break_since + (g.hard_punishment_minutes || ' minutes')::interval
      )
    when me.status = 'alive' then jsonb_build_object('active', false)
    else null
  end;

  if me.status = 'dead' then
    if me.killed_by is not null then
      select name_ciphertext into killer_name from public.players where id = me.killed_by;
    end if;
    return jsonb_build_object(
      'game_status', g.status, 'next_pulse_at', g.next_pulse_at,
      'active_warning', active_warning,
      'event', 'you_died', 'payload', jsonb_build_object(
        'cause', me.death_cause,
        'killer_name_ciphertext', killer_name,
        'photo_path', me.death_photo_path,
        'survived_seconds', extract(epoch from
          coalesce(me.died_at, now()) - coalesce(g.active_at, me.joined_at))::int
      ));
  end if;

  if g.status = 'dispersing' then
    return jsonb_build_object(
      'game_status', g.status, 'next_pulse_at', g.next_pulse_at,
      'active_warning', active_warning,
      'event', 'dispersal_started', 'payload', jsonb_build_object(
        'ends_at', g.started_at + (g.disperse_minutes || ' minutes')::interval
      ));
  end if;

  if g.status = 'active' and me.target_id is not null then
    select * into t from public.players where id = me.target_id;
    return jsonb_build_object(
      'game_status', g.status, 'next_pulse_at', g.next_pulse_at,
      'active_warning', active_warning,
      'event', 'target_assigned', 'payload', jsonb_build_object(
        'target_id', t.id,
        'name_ciphertext', t.name_ciphertext,
        'selfie_path', t.selfie_path
      ));
  end if;

  return jsonb_build_object(
    'game_status', g.status, 'next_pulse_at', g.next_pulse_at,
    'active_warning', active_warning,
    'event', null, 'payload', '{}'::jsonb
  );
end $$;

revoke execute on function get_my_state(uuid) from public, anon;
grant execute on function get_my_state(uuid) to authenticated;
