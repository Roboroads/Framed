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
  -- Same 2048 ceiling as name_ciphertext (13-lobby.sql) — comfortably
  -- covers the client's own maxLength on plaintext (#80).
  if coalesce(p_ciphertext, '') = '' or length(p_ciphertext) > 2048 then
    raise exception using message = 'message_too_long';
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

-- get_dead_players(game_id) -> every dead player's id + encrypted name
-- (#80), same access rule as chat (framed_can_chat): dead any time, or
-- anyone once the game's finished. The death screen uses this for "who
-- else is out" context — a one-time snapshot on load, not live-updated,
-- same as how the roster is fetched for chat sender names elsewhere.
create or replace function get_dead_players(p_game_id uuid)
returns table(player_id uuid, name_ciphertext text)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.framed_can_chat(p_game_id) then
    raise exception using message = 'cannot_view';
  end if;

  return query
    select p.id, p.name_ciphertext from public.players p
    where p.game_id = p_game_id and p.status = 'dead'
    order by p.died_at;
end $$;

revoke execute on function get_dead_players(uuid) from public, anon;
grant execute on function get_dead_players(uuid) to authenticated;
