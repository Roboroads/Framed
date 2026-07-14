-- Framed frame submission: held frames, cooldown, judge fan-out (issue #19).
-- Idempotent. Resolution (votes, verdicts, deaths) is #20.

-- Judge count per frame, frozen at creation: #20's vote math needs the
-- judge count as of the frame's creation, not a live count, so a death
-- mid-vote can't move the goalposts.
alter table frames add column if not exists judge_count integer;

-- Fan a pending frame out to every judge: all players but the assassin and
-- target, alive or dead. Shared with #20, which calls this when a held
-- frame is released and becomes pending.
create or replace function notify_judges(p_frame_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  f public.frames%rowtype;
  target public.players%rowtype;
  j public.players%rowtype;
begin
  select * into f from public.frames where id = p_frame_id;
  select * into target from public.players where id = f.target_id;
  for j in select * from public.players
    where game_id = f.game_id and id not in (f.assassin_id, f.target_id)
  loop
    perform public.emit('player:' || j.id, 'frame_to_judge',
      jsonb_build_object(
        'frame_id', f.id,
        'photo_path', f.photo_path,
        'target_name_ciphertext', target.name_ciphertext,
        'target_selfie_path', target.selfie_path));
    perform public.enqueue_push(j.id, 'frame_to_judge');
  end loop;
end $$;

-- submit_frame(game_id, photo_path) -> frame_id. The client uploads the
-- encrypted photo to frames/{game_id}/{uuid} first (storage policy in
-- 11-policies.sql), then calls this with that same uuid as photo_path.
create or replace function submit_frame(game_id uuid, photo_path text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  g public.games%rowtype;
  me public.players%rowtype;
  held boolean;
  new_id uuid;
begin
  select * into g from public.games where id = submit_frame.game_id;
  if not found then raise exception using message = 'not_found'; end if;

  select * into me from public.players p
    where p.game_id = submit_frame.game_id and p.auth_uid = auth.uid()
    for update;
  if not found then raise exception using message = 'not_member'; end if;
  if me.status <> 'alive' or g.status <> 'active' then
    raise exception using message = 'wrong_status';
  end if;
  if me.frame_cooldown_until is not null and now() < me.frame_cooldown_until then
    raise exception using message = 'on_cooldown';
  end if;
  -- the #2 partial unique index (frames_one_open_per_assassin) backs this;
  -- the "for update" lock above serializes concurrent submits from the
  -- same assassin so this check can't race itself.
  if exists (select 1 from public.frames
             where assassin_id = me.id and status in ('held', 'pending')) then
    raise exception using message = 'frame_already_pending';
  end if;
  if array_length(string_to_array(photo_path, '/'), 1) <> 2
     or (string_to_array(photo_path, '/'))[1] <> submit_frame.game_id::text
     or not exists (select 1 from storage.objects o
                    where o.bucket_id = 'frames' and o.name = submit_frame.photo_path) then
    raise exception using message = 'not_found';
  end if;

  -- held: a frame targeting me is already pending, so my verdict must
  -- resolve first (the dead can't kill). No event distinguishes held from
  -- pending here — the submitter must not be able to tell the two apart.
  held := exists (select 1 from public.frames
                  where target_id = me.id and status = 'pending');

  insert into public.frames
    (game_id, assassin_id, target_id, photo_path, status, pending_since, resolves_at, judge_count)
  values (
    me.game_id, me.id, me.target_id, submit_frame.photo_path,
    case when held then 'held' else 'pending' end::public.frame_status,
    case when held then null else now() end,
    case when held then null else now() + (g.vote_timeout_minutes || ' minutes')::interval end,
    (select count(*) from public.players p2 where p2.game_id = me.game_id) - 2
  )
  returning id into new_id;

  if not held then
    perform public.notify_judges(new_id);
  end if;

  return new_id;
end $$;

revoke execute on function notify_judges(uuid) from public, anon, authenticated;
revoke execute on function submit_frame(uuid, text) from public, anon;
grant execute on function submit_frame(uuid, text) to authenticated;
