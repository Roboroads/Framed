-- Framed RLS + storage policies: need-to-know access (issue #3).
-- Idempotent. Applied by the framed-sql one-shot service after db AND storage
-- are healthy (storage.objects does not exist at initdb time).
--
-- Model: all app access is the `authenticated` role via anonymous auth.
-- State changes go through security definer RPCs; these policies cover reads
-- plus the few direct writes (own push_token, dead chat).

-- Helpers: security definer (owner bypasses RLS) so policies can look at
-- players without recursing into players' own policies.

create or replace function framed_uuid(t text) returns uuid
language plpgsql immutable as $$
begin
  return t::uuid;
exception when invalid_text_representation then
  return null;
end $$;

-- Your player row in a game; null when you are not in it
create or replace function framed_my_player(gid uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select id from public.players where game_id = gid and auth_uid = auth.uid()
$$;

create or replace function framed_i_am_dead(gid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select status = 'dead' from public.players
      where game_id = gid and auth_uid = auth.uid()),
    false)
$$;

-- Supabase default ACLs grant execute on new public functions to anon and
-- authenticated directly — revoke those, not just public
revoke execute on function framed_uuid(text), framed_my_player(uuid), framed_i_am_dead(uuid) from public, anon;
grant execute on function framed_uuid(text), framed_my_player(uuid), framed_i_am_dead(uuid) to authenticated;

-- Baseline: the app roles get nothing, then exactly what the design allows.
-- service_role keeps full access (it bypasses RLS by role attribute anyway).
revoke all on games, players, frames, frame_votes, chat_messages, aggregate_stats
  from anon, authenticated;
grant all on games, players, frames, frame_votes, chat_messages, aggregate_stats
  to service_role;

-- games: members read their own game. No writes; no path to look up by token
-- (join_game resolves tokens inside a definer function).
grant select on games to authenticated;
drop policy if exists games_member_select on games;
create policy games_member_select on games
  for select to authenticated
  using (framed_my_player(id) is not null);

-- players: members read their game's roster, but only the public columns.
-- Locations, targets, push tokens, counters and death details reach clients
-- only through realtime events.
grant select (id, game_id, name_ciphertext, selfie_path, is_host, status, joined_at)
  on players to authenticated;
drop policy if exists players_member_select on players;
create policy players_member_select on players
  for select to authenticated
  using (framed_my_player(game_id) is not null);

-- players: you may update your own push_token, nothing else
grant update (push_token) on players to authenticated;
drop policy if exists players_own_update on players;
create policy players_own_update on players
  for update to authenticated
  using (auth_uid = (select auth.uid()))
  with check (auth_uid = (select auth.uid()));

-- frames, frame_votes, aggregate_stats: no direct access at all.
-- Judges learn about frames from events; votes go through cast_vote.
-- (Nothing granted above, RLS enabled in 10-schema.sql — default deny.)

-- chat_messages: dead players of the game only, sender must be yourself
grant select, insert on chat_messages to authenticated;
drop policy if exists chat_dead_select on chat_messages;
create policy chat_dead_select on chat_messages
  for select to authenticated
  using (framed_i_am_dead(game_id));
drop policy if exists chat_dead_insert on chat_messages;
create policy chat_dead_insert on chat_messages
  for insert to authenticated
  with check (framed_i_am_dead(game_id) and sender_id = framed_my_player(game_id));

-- Storage: two private buckets. Every blob is AES-GCM ciphertext; these
-- policies are defense in depth, need-to-know routing happens at the event
-- layer. Paths: selfies/{game_id}/{player_id}, frames/{game_id}/{frame_id}.
insert into storage.buckets (id, name, public)
values ('selfies', 'selfies', false), ('frames', 'frames', false)
on conflict (id) do nothing;

-- selfies: upload (and re-upload) only to your own exact path in your game
drop policy if exists framed_selfies_insert on storage.objects;
create policy framed_selfies_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'selfies'
    and name = (string_to_array(name, '/'))[1] || '/'
        || framed_my_player(framed_uuid((string_to_array(name, '/'))[1]))::text
  );
drop policy if exists framed_selfies_update on storage.objects;
create policy framed_selfies_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'selfies'
    and name = (string_to_array(name, '/'))[1] || '/'
        || framed_my_player(framed_uuid((string_to_array(name, '/'))[1]))::text
  )
  with check (
    bucket_id = 'selfies'
    and name = (string_to_array(name, '/'))[1] || '/'
        || framed_my_player(framed_uuid((string_to_array(name, '/'))[1]))::text
  );

-- frames: members upload under their game's prefix ({game_id}/{frame_id};
-- the frame id does not exist server-side until submit_frame, so exact-path
-- can't be checked here)
drop policy if exists framed_frames_insert on storage.objects;
create policy framed_frames_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'frames'
    and array_length(string_to_array(name, '/'), 1) = 2
    and framed_my_player(framed_uuid((string_to_array(name, '/'))[1])) is not null
  );

-- read (signed URLs): members of the game only
drop policy if exists framed_objects_select on storage.objects;
create policy framed_objects_select on storage.objects
  for select to authenticated
  using (
    bucket_id in ('selfies', 'frames')
    and framed_my_player(framed_uuid((string_to_array(name, '/'))[1])) is not null
  );
