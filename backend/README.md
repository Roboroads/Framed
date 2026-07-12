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
