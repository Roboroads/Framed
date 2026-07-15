-- Framed realtime plumbing: private broadcast channels + emit() helper (issue #4).
-- Idempotent. Requires realtime.messages (framed-sql waits for the realtime
-- service before applying).
--
-- Topic and event catalogue (spec: plan doc "Realtime contract"). Payloads
-- carry ciphertext and storage paths, NEVER plaintext names or photo bytes —
-- emit() cannot check that, the emitting code must.
--
--   game:{game_id}        — players of that game
--     player_joined   {player_id, name_ciphertext}
--     player_ready    {player_id}
--     player_left     {player_id}
--     host_changed    {player_id}
--     settings_changed{settings}
--     dispersal_started {ends_at}
--     game_finished   {winner_id, stats, kill_chain}
--     replay_started  {new_game_id, key_ciphertext, join_token}
--
--   player:{player_id}    — that player only
--     target_assigned {target_id, name_ciphertext, selfie_path}
--     compass_pulse   {bearing_deg, distance_m, expires_at, next_pulse_at}
--     frame_to_judge  {frame_id, photo_path, target_name_ciphertext, target_selfie_path}
--     frame_verdict   {passed, cooldown_until, reason}
--     you_died        {cause, killer_name_ciphertext, photo_path, survived_seconds}
--     warning         {active, reasons[], hard_deadline}
--     geofence_proximity {active}
--     target_location {lat, lng}
--
--   game:{game_id}:dead   — dead players any time, or any member once the
--                           game has finished (#79)
--     chat_message    {sender_id, ciphertext, created_at}

-- Is this player id me? (security definer: bypasses players RLS, like the
-- helpers in 11-policies.sql)
create or replace function framed_is_me(pid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.players where id = pid and auth_uid = auth.uid())
$$;
revoke execute on function framed_is_me(uuid) from public, anon;
grant execute on function framed_is_me(uuid) to authenticated;

-- Game logic emits every event through this:
--   perform emit('player:' || target_id, 'you_died', jsonb_build_object(...));
-- Only server-side definer functions call it — no grant to app roles.
create or replace function emit(p_topic text, p_event text, p_payload jsonb)
returns void language sql as $$
  select realtime.send(p_payload, p_event, p_topic, true)
$$;
-- default ACLs auto-grant execute to app roles; strip them (clients could not
-- spoof anyway — no insert policy on realtime.messages — but don't even allow
-- the call)
revoke execute on function emit(text, text, jsonb) from public, anon, authenticated;

-- Subscribe authorization for the three topic shapes. Private channels only:
-- realtime checks this select policy on join when the client sets private=true
-- (public channels stay unusable for authenticated — no other policy exists).
drop policy if exists framed_topics on realtime.messages;
create policy framed_topics on realtime.messages
  for select to authenticated
  using (
    extension = 'broadcast'
    and (
      -- game:{game_id}:dead — dead members, or anyone once finished (#79)
      (realtime.topic() like 'game:%:dead'
        and framed_can_chat(framed_uuid(split_part(realtime.topic(), ':', 2))))
      -- game:{game_id} — members
      or (realtime.topic() like 'game:%' and realtime.topic() not like 'game:%:%'
        and framed_my_player(framed_uuid(split_part(realtime.topic(), ':', 2))) is not null)
      -- player:{player_id} — that player only
      or (realtime.topic() like 'player:%'
        and framed_is_me(framed_uuid(split_part(realtime.topic(), ':', 2))))
    )
  );
