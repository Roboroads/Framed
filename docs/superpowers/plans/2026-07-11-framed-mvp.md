# Framed MVP implementation plan

> **For agentic workers:** the tasks for this plan live as GitHub issues on Roboroads/Framed (see issue #1, the roadmap). Pick an issue, check its "blocked by" list is closed, then implement it with superpowers:subagent-driven-development or superpowers:executing-plans. This document holds the contracts every issue shares — read it before starting any issue. [IDEA.md](../../../IDEA.md) stays the single source of truth for game design; if this document and IDEA.md disagree, IDEA.md wins and this document has a bug.

**Goal:** ship the Framed MVP — a working IRL assassination game for 3+ players on Android and iOS, backed by self-hosted Supabase.

**Architecture:** the server is the game master. All game state lives in Postgres and is advanced by SQL functions on a 30-second cron tick; clients call RPCs, subscribe to realtime channels, and render what they receive. Game content the server doesn't need for authority (names, selfies, frame photos, dead-chat) is AES-GCM encrypted on-device with a per-game key the server never sees.

**Tech stack:** Flutter (flutter_bloc + freezed, get_it, slang), self-hosted Supabase (Postgres 15, PostGIS, pg_cron, Realtime, Storage, Edge Functions), FCM + APNs for data-only push.

## Global constraints

- All user-facing strings go through slang. All colors come from `lib/core/theme/app_theme.dart`.
- Clean architecture, feature-first: `lib/features/<feature>/{data,domain,presentation}`.
- No analytics, tracking, or crash-reporting dependencies. Ever.
- The game key travels only inside the QR code (and, on replay, encrypted under the old key). It never reaches the server in any form. HMAC of the name (keyed by the game key) is the one derived value the server stores.
- Locations are plaintext server-side; only last-known is stored, never a track.
- Conventional commits. `dart format .`, `flutter analyze`, `flutter test` green before every commit.
- Backend migrations live in `backend/volumes/db/init/` for local dev; each issue that touches the schema adds an idempotent SQL file there (numbered, e.g. `10-schema.sql`).

## Data model

All tables in schema `public`, RLS enabled on every one. Enums:

```sql
create type game_status  as enum ('lobby', 'dispersing', 'active', 'finished');
create type game_mode    as enum ('most_frames', 'last_man_standing');
create type player_status as enum ('alive', 'dead');
create type death_cause  as enum ('framed', 'mia');
create type frame_status as enum ('held', 'pending', 'passed', 'failed', 'void');
```

### games

| column | type | notes |
|---|---|---|
| id | uuid pk | `gen_random_uuid()` |
| status | game_status | default `'lobby'` |
| mode | game_mode | default `'most_frames'`; host-set in the lobby like any other setting. Gameplay is identical in both modes — only the winner computation differs |
| join_token | text unique | 128-bit random base64url; set to NULL at game start (tokens die with the lobby) |
| host_player_id | uuid | fk players, deferred |
| geofence_center | geography(Point,4326) | set by host |
| geofence_radius_m | integer | |
| disperse_minutes | integer | default 10 |
| soft_punishment_minutes | integer | default 2 |
| hard_punishment_minutes | integer | default 5 |
| compass_update_interval_minutes | integer | default 10 |
| compass_view_seconds | integer | default 30 |
| vote_timeout_minutes | integer | default 5 |
| frame_cooldown_minutes | integer | default 5 |
| next_pulse_at | timestamptz | maintained by the tick |
| replay_of | uuid | fk games; set on "replay with same players" |
| replay_key_ciphertext | text | new game key encrypted under the old key, relayed by the server, opaque to it |
| winner_player_id | uuid | |
| created_at / started_at / active_at / finished_at | timestamptz | started_at = dispersal begins, active_at = dispersal ends |

### players

| column | type | notes |
|---|---|---|
| id | uuid pk | |
| game_id | uuid fk | |
| auth_uid | uuid | Supabase anonymous-auth user id; unique per game |
| name_ciphertext | text | AES-GCM blob, base64 |
| name_hmac | text | HMAC-SHA256(game key, lowercased name); unique `(game_id, name_hmac)` — this is how the server rejects duplicate names it cannot read |
| selfie_path | text | Storage path of the encrypted reference selfie; NULL until uploaded (player counts as "ready" once set) |
| push_token | text | FCM/APNs token |
| platform | text | `'android'` or `'ios'` |
| is_host | boolean | mirrors games.host_player_id |
| status | player_status | default `'alive'` |
| death_cause / died_at / killed_by / death_photo_path | | filled on death; killed_by NULL for MIA |
| target_id | uuid fk players | the circle: NULL until game start |
| last_location | geography(Point,4326) | last known only, overwritten each update |
| last_location_at | timestamptz | staleness = now() - this > 90s |
| outside_geofence_since | timestamptz | NULL while inside |
| rule_break_since | timestamptz | earliest of the active rule breaks; drives punishment timers |
| frame_cooldown_until | timestamptz | |
| distance_moved_m | double precision | running counter, incremented per location update |
| still_seconds | integer | running counter (update moved < 5 m from previous) |
| kills | integer | |
| joined_at | timestamptz | host transfer goes to the smallest value |

### frames

| column | type | notes |
|---|---|---|
| id | uuid pk | |
| game_id / assassin_id / target_id | fk | |
| photo_path | text | Storage path of the encrypted photo |
| status | frame_status | `held` while the assassin's own verdict is pending, else `pending` |
| created_at / pending_since / resolves_at | timestamptz | resolves_at = pending_since + vote_timeout_minutes |

### frame_votes

`(frame_id, judge_id)` pk, `vote boolean`, `created_at`. One row per judge per frame; no updates.

### chat_messages

`id, game_id, sender_id, ciphertext, created_at`. Insertable and readable by dead players of that game only.

### aggregate_stats

The only table that survives cleanup. No foreign keys, no ids, no locations: `finished_on date, player_count int, duration_minutes int, autocleaned boolean`. One row appended per finished or auto-cleaned game.

## RPC contract

All RPCs are `security definer` SQL functions callable via `supabase.rpc()`. The caller is identified by `auth.uid()` (Supabase anonymous auth — the app signs in anonymously once at first launch). Errors are raised with stable message codes the app can match on (`name_taken`, `not_host`, `too_few_players`, `on_cooldown`, `frame_already_pending`, `not_dead`, `wrong_status`).

| function | args | returns | notes |
|---|---|---|---|
| create_game | settings jsonb | `{game_id, join_token}` | creates game + host player row (host joins like everyone else afterwards is wrong — the host IS a player; create_game also creates the host's player row from name_ciphertext/name_hmac in the jsonb) |
| update_settings | game_id, settings jsonb | void | host only, status `lobby` only |
| join_game | join_token, name_ciphertext, name_hmac, push_token, platform | `{game_id, player_id}` | raises `name_taken` on hmac conflict |
| leave_lobby | game_id | void | lobby only; if the host leaves, host role moves to the earliest joined_at |
| start_game | game_id | void | host only, ≥3 players with selfie_path set; shuffles the circle, status → `dispersing` |
| submit_location | game_id, lat double, lng double | void | alive players, status dispersing/active; updates counters |
| submit_frame | game_id, photo_path | frame_id | alive, active, not on cooldown, no open frame; status `held` if a frame on the assassin is pending, else `pending` |
| cast_vote | frame_id, vote boolean | void | judges only (alive+dead, not assassin, not target); resolves immediately when mathematical majority reached |
| send_chat | game_id, ciphertext | message_id | dead senders only |
| replay_game | game_id, key_ciphertext, settings jsonb | new_game_id | host only, status finished; copies players (names, selfies, hmacs) into a new lobby |
| leave_finished_game | game_id | void | marks the player gone; when everyone is gone the game is wiped |

## The tick

One pg_cron entry, every 30 seconds: `select game_tick()`. It advances every non-finished game:

1. End dispersal: `dispersing` games past `started_at + disperse_minutes` → status `active`, everyone gets `target_assigned`, first `next_pulse_at` set.
2. Staleness and geofence: recompute `rule_break_since` per alive player; past `soft_punishment_minutes` → assassin gets `target_location` events; past `hard_punishment_minutes` → MIA death.
3. Compass pulses: games past `next_pulse_at` → send `compass_pulse` to each eligible alive player (not rule-breaking, not stale, no unvoted pending frame as judge), advance `next_pulse_at`.
4. Vote timeouts: `pending` frames past `resolves_at` → resolve on votes cast (tie or zero = failed).
5. Win check: one alive player left → status `finished`. Winner by mode: `last_man_standing` → the survivor; `most_frames` → highest `kills`, ties broken by longest survival (the survivor wins any tie they are part of; a dead player can win outright).
6. Cleanup: finished games and games older than 24h → wipe (see issue on cleanup).

Everything the tick decides fans out as realtime events + push. Clients never compute outcomes.

## Realtime contract

Supabase Realtime **private broadcast channels** (`realtime.send()` from SQL), authorized by RLS on `realtime.messages`:

| topic | who may subscribe | events |
|---|---|---|
| `game:{game_id}` | players of that game | `player_joined`, `player_left`, `host_changed`, `settings_changed`, `dispersal_started {ends_at}`, `game_finished {winner_id, stats, kill_chain}`, `replay_started {new_game_id, key_ciphertext, join…}` |
| `player:{player_id}` | that player | `target_assigned {target_id, name_ciphertext, selfie_path}`, `compass_pulse {bearing_deg, distance_m, expires_at}`, `frame_to_judge {frame_id, photo_path, target_name_ciphertext, target_selfie_path}`, `frame_verdict {passed, cooldown_until}`, `you_died {cause, killer_name_ciphertext, photo_path, survived_seconds}`, `warning {active, reasons[], hard_deadline}`, `target_location {lat, lng}` |
| `game:{game_id}:dead` | dead players of that game | `chat_message {sender_id, ciphertext, created_at}` |

Event payloads never contain plaintext names or photo bytes — ciphertext and storage paths only.

## Storage

Two private buckets, no public access, blobs are AES-GCM ciphertext anyway:

- `selfies/{game_id}/{player_id}` — reference selfie, uploaded at pre-join.
- `frames/{game_id}/{frame_id}` — frame photos.

Reads go through short-lived signed URLs; storage RLS restricts creation to the owning player and reads to players of the game (need-to-know narrowing happens at the event-routing layer — only judges ever learn a frame's path).

## Crypto (client-side, `lib/core/crypto/`)

- One 256-bit AES-GCM game key, generated on the host device at create-game.
- QR payload: `framed://join?v=1&t={join_token}&k={base64url key}`. The key exists only in this payload and on player devices; the app never puts it in a network call.
- `encrypt(bytes) → base64(nonce ‖ ciphertext ‖ tag)` with a fresh 96-bit nonce per message; `decrypt` reverses it. Names, selfies, frame photos, chat all use this one shape.
- `nameHmac(name) = hex(HMAC-SHA256(key, lowercase(trim(name))))`.

## Build order

Milestones map 1:1 to GitHub milestones. Within a milestone, issues are ordered; backend before the app screen that consumes it.

1. **M1 Server foundation** — schema, RLS + storage policies, lobby RPCs, game start, realtime fan-out.
2. **M2 App foundation** — crypto core, host flow, join flow, lobby screen, ingame skeleton.
3. **M3 Location & compass** — location pipeline, geofence punishments, background service, warning modal, pulse engine, compass UI, soft-punish map.
4. **M4 Kill loop** — frame backend, vote resolution, frame camera, judging modal.
5. **M5 Death & finish** — death screen, dead chat, win/stats/replay backend, finish screen.
6. **M6 Notifications, cleanup, release** — data-only push (backend + app), cleanup/retention, privacy policy, real-device validation.

The game is playable end-to-end (minus pocket notifications) after M4; M5 makes it complete; M6 makes it shippable.
