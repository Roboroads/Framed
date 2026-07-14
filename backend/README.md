# Framed backend — local dev

Vendored from the official [supabase/supabase docker setup](https://github.com/supabase/supabase/tree/master/docker), with PostGIS enabled in `volumes/db/init/00-postgis.sql`.

## Run

```sh
cd backend
docker compose up -d
```

- API (Kong): http://localhost:8000
- Studio: http://localhost:8000 (login: see `DASHBOARD_USERNAME`/`DASHBOARD_PASSWORD` in `.env`)
- Postgres: `postgresql://postgres:<POSTGRES_PASSWORD>@localhost:5432/postgres`

The app connects with `SUPABASE_PUBLIC_URL` + `ANON_KEY` from `.env` (see `lib/core/config/env.dart`).

Anonymous sign-ins are enabled (`ENABLE_ANONYMOUS_USERS=true` in `.env`) — every RPC identifies the caller by `auth.uid()` from Supabase anonymous auth.

The `framed-sql` one-shot container applies `volumes/db/init/*.sql` (idempotent schema + policies) on every `docker compose up`, after db and storage are healthy.

## Reset

```sh
./reset.sh   # wipes all data and volumes
```

## Secrets

`.env` contains the **publicly documented demo keys** — fine for local dev only.
For the EU production server, regenerate `POSTGRES_PASSWORD`, `JWT_SECRET`, `ANON_KEY`, `SERVICE_ROLE_KEY`, and the dashboard login per the [self-hosting guide](https://supabase.com/docs/guides/self-hosting/docker#securing-your-services). Never commit that `.env`.

## Push notifications (issue #27)

The `push` Edge Function (`volumes/functions/push/`) sends the data-only
wake-up push described in IDEA.md "Notifications". Without these set, it
logs what it would have sent instead of sending — the local stack runs
clean with zero setup:

- `FCM_SERVICE_ACCOUNT_JSON` — the full service account JSON (as a string)
  for an Android FCM project.
- `APNS_KEY_P8` — the `.p8` private key contents for iOS APNs token auth.
- `APNS_KEY_ID`, `APNS_TEAM_ID` — from the Apple Developer portal, paired
  with the key above.
- `APNS_BUNDLE_ID` — defaults to `me.roboroads.framed`.

No Firebase project or APNs credentials exist for this app yet — real key
provisioning and live push delivery are tracked separately (#31).
