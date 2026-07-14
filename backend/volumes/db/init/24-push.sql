-- Framed data-only push: outbox + edge function trigger (issue #27).
-- Idempotent. The push Edge Function (backend/volumes/functions/push) reads
-- unsent rows, sends FCM/APNs data messages ({event, game_id} only — see
-- IDEA.md "End-to-end encryption"), and stamps sent_at. Local dev with no
-- provider keys configured: the function logs instead of sending and still
-- marks rows sent, so the compose stack stays green with zero setup (see
-- the decision recorded on #27 — real key provisioning is out of scope
-- here).

create extension if not exists pg_net;

create table if not exists push_outbox (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references players (id) on delete cascade,
  game_id uuid not null references games (id) on delete cascade,
  event text not null,
  created_at timestamptz not null default now(),
  sent_at timestamptz
);

create index if not exists push_outbox_unsent_idx on push_outbox (id)
  where sent_at is null;

alter table push_outbox enable row level security;
-- Default-deny: no client reads or writes this table at all, ever — it's
-- the server's own delivery queue, entirely opaque to the app.
revoke all on push_outbox from anon, authenticated;

-- enqueue_push(player_id, event): the one call site every attention-event
-- emitter adds alongside its existing `emit()`. game_id is derived, not
-- passed — callers already know the player, not necessarily the game row.
-- A player_id that resolves to nothing (shouldn't happen) is a silent
-- no-op, matching kill_player's not-found tolerance elsewhere.
create or replace function enqueue_push(p_player_id uuid, p_event text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_game_id uuid;
begin
  select game_id into v_game_id from public.players where id = p_player_id;
  if v_game_id is null then return; end if;
  insert into public.push_outbox (player_id, game_id, event)
    values (p_player_id, v_game_id, p_event);
end $$;

revoke execute on function enqueue_push(uuid, text) from public, anon, authenticated;

-- Ping the function once per insert statement (not per row — a single
-- multi-row enqueue, e.g. game_finished fanning out to every player,
-- shouldn't fire N pings). The function itself sweeps every unsent row,
-- not just what triggered it, so a missed or coalesced ping is
-- self-healing rather than a lost push.
create or replace function notify_push_outbox() returns trigger
language plpgsql set search_path = '' as $$
begin
  -- functions:9000 is this compose network's edge-runtime container,
  -- reachable from db without going through Kong. Production deployment
  -- needs this pointed at the real function URL — out of scope here, see
  -- #27's decision comment (no provider keys yet either).
  perform net.http_post(
    url := 'http://functions:9000/push',
    body := '{}'::jsonb
  );
  return null;
end $$;

drop trigger if exists push_outbox_notify on push_outbox;
create trigger push_outbox_notify
  after insert on push_outbox
  for each statement execute function notify_push_outbox();
