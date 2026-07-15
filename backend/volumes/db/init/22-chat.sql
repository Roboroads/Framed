-- Framed dead chat: send_chat RPC (issue #24, broadened to the finish
-- screen too by #79). Idempotent. Table + RLS already exist
-- (11-policies.sql); this just adds the write path and its fan-out.

-- send_chat: caller must be dead, or the game must be finished (RLS on the
-- insert enforces this too, via framed_can_chat — but checking here lets
-- us raise a clear error instead of a bare RLS violation).
create or replace function send_chat(p_game_id uuid, p_ciphertext text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me public.players%rowtype;
  msg public.chat_messages%rowtype;
begin
  select * into me from public.players
    where game_id = p_game_id and auth_uid = auth.uid();
  if not found then raise exception using message = 'not_member'; end if;
  if not public.framed_can_chat(p_game_id) then
    raise exception using message = 'cannot_chat';
  end if;

  insert into public.chat_messages (game_id, sender_id, ciphertext)
  values (p_game_id, me.id, p_ciphertext)
  returning * into msg;

  perform public.emit('game:' || p_game_id || ':dead', 'chat_message',
    jsonb_build_object(
      'message_id', msg.id,
      'sender_id', msg.sender_id,
      'ciphertext', msg.ciphertext,
      'created_at', msg.created_at
    ));

  return msg.id;
end $$;

revoke execute on function send_chat(uuid, text) from public, anon;
grant execute on function send_chat(uuid, text) to authenticated;
