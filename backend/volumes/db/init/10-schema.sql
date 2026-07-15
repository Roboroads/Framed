-- Framed schema. Spec: docs/superpowers/plans/2026-07-11-framed-mvp.md "Data model".
-- Idempotent: safe to run on a live database. Loaded at initdb via docker-compose
-- mounts; apply to a running db with psql -f.

-- Enums (create type has no "if not exists")
do $$ begin
  create type game_status as enum ('lobby', 'dispersing', 'active', 'finished');
exception when duplicate_object then null; end $$;

do $$ begin
  create type game_mode as enum ('most_frames', 'last_man_standing');
exception when duplicate_object then null; end $$;

do $$ begin
  create type player_status as enum ('alive', 'dead');
exception when duplicate_object then null; end $$;

do $$ begin
  create type death_cause as enum ('framed', 'mia');
exception when duplicate_object then null; end $$;

-- 'left' (#78): a living player leaving mid-game (dispersing or active) —
-- distinct from 'mia' since it's a deliberate quit, not a punishment.
-- ALTER TYPE ... ADD VALUE can't run inside the DO block above (can't be
-- combined with other DDL in one transaction with the type's own creation),
-- so it's its own statement here instead.
alter type death_cause add value if not exists 'left';

do $$ begin
  create type frame_status as enum ('held', 'pending', 'passed', 'failed', 'void');
exception when duplicate_object then null; end $$;

create table if not exists games (
  id uuid primary key default gen_random_uuid(),
  status game_status not null default 'lobby',
  mode game_mode not null default 'most_frames',
  join_token text unique, -- nulled at game start: tokens die with the lobby
  host_player_id uuid,    -- fk added below (circular with players)
  geofence_center geography(point, 4326),
  geofence_radius_m integer,
  disperse_minutes integer not null default 10,
  soft_punishment_minutes integer not null default 2,
  hard_punishment_minutes integer not null default 5,
  compass_update_interval_minutes integer not null default 5,
  compass_view_seconds integer not null default 30,
  vote_timeout_minutes integer not null default 5,
  frame_cooldown_minutes integer not null default 2,
  next_pulse_at timestamptz,
  replay_of uuid references games (id),
  replay_key_ciphertext text, -- new game key under the old key; opaque to the server
  winner_player_id uuid,
  created_at timestamptz not null default now(),
  started_at timestamptz,  -- dispersal begins
  active_at timestamptz,   -- dispersal ends
  finished_at timestamptz
);

create table if not exists players (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references games (id) on delete cascade,
  auth_uid uuid not null,
  name_ciphertext text not null,
  -- HMAC-SHA256(game key, lowercased name): duplicate names rejected by the db
  -- even though the server cannot read them
  name_hmac text not null,
  selfie_path text, -- player counts as "ready" once set
  push_token text,
  platform text check (platform in ('android', 'ios')),
  is_host boolean not null default false,
  status player_status not null default 'alive',
  death_cause death_cause,
  died_at timestamptz,
  killed_by uuid references players (id) on delete set null, -- null for MIA
  death_photo_path text,
  -- the circle; null until game start. set null (not cascade): deleting a player
  -- must never chain-delete whoever targets them
  target_id uuid references players (id) on delete set null,
  last_location geography(point, 4326),   -- last known only, overwritten each update
  last_location_at timestamptz,
  outside_geofence_since timestamptz,
  rule_break_since timestamptz,
  frame_cooldown_until timestamptz,
  distance_moved_m double precision not null default 0,
  still_seconds integer not null default 0,
  kills integer not null default 0,
  joined_at timestamptz not null default now(),
  -- Lobby-only liveness signal (#70): bumped by the client's heartbeat RPC
  -- while waiting in the lobby, otherwise unused (ingame liveness already
  -- has last_location_at/is_stale). Defaults to joined_at's value so a
  -- player who joins and immediately goes dark still has a real timestamp
  -- to expire from, not an artificial "just seen".
  last_seen timestamptz not null default now(),
  unique (game_id, auth_uid),  -- one seat per device per game
  unique (game_id, name_hmac)  -- unique names, unreadable by the server
);

do $$ begin
  alter table games add constraint games_host_player_id_fkey
    foreign key (host_player_id) references players (id)
    deferrable initially deferred;
exception when duplicate_object then null; end $$;

create table if not exists frames (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references games (id) on delete cascade,
  assassin_id uuid not null references players (id) on delete cascade,
  target_id uuid not null references players (id) on delete cascade,
  photo_path text not null,
  status frame_status not null,
  created_at timestamptz not null default now(),
  resolves_at timestamptz -- set when entering 'pending': now() + vote_timeout_minutes
);

-- One open frame per assassin, enforced by the database
create unique index if not exists frames_one_open_per_assassin
  on frames (assassin_id) where status in ('held', 'pending');

create table if not exists frame_votes (
  frame_id uuid not null references frames (id) on delete cascade,
  judge_id uuid not null references players (id) on delete cascade,
  vote boolean not null,
  created_at timestamptz not null default now(),
  primary key (frame_id, judge_id) -- one vote per judge per frame, no updates
);

create table if not exists chat_messages (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references games (id) on delete cascade,
  sender_id uuid not null references players (id) on delete cascade,
  ciphertext text not null,
  created_at timestamptz not null default now()
);

-- The only table that survives cleanup. No foreign keys, no ids, no locations.
create table if not exists aggregate_stats (
  finished_on date not null,
  player_count integer not null,
  duration_minutes integer not null,
  autocleaned boolean not null
);

-- Tick indexes. players(game_id) is covered by the unique (game_id, auth_uid) index.
create index if not exists frames_pending_idx
  on frames (game_id) where status = 'pending';
create index if not exists games_next_pulse_idx
  on games (next_pulse_at) where status = 'active';

-- Default-deny until #3 adds policies
alter table games enable row level security;
alter table players enable row level security;
alter table frames enable row level security;
alter table frame_votes enable row level security;
alter table chat_messages enable row level security;
alter table aggregate_stats enable row level security;
