# Framed

A local-area circular assassination game you play IRL — GPS-assisted, photo-based. Two game modes: most frames wins (default) or last player standing.

**[IDEA.md](IDEA.md)** holds the full game design.

## Development

```sh
# Local backend (self-hosted Supabase + PostGIS)
cd backend && cp .env.example .env && docker compose up -d && cd ..

# App
flutter pub get
dart run build_runner build -d   # freezed + slang codegen
flutter run                       # Android emulator: add --dart-define=SUPABASE_URL=http://10.0.2.2:8000
```

Checks: `dart format .` · `flutter analyze` · `flutter test`

## Structure

- `lib/features/<feature>/{data,domain,presentation}` — clean architecture, feature-first
- `lib/core/` — theme (design system), DI, config, crypto
- `backend/` — Supabase docker-compose for local dev ([backend/README.md](backend/README.md))
- Contributor/AI guidelines: [CLAUDE.md](CLAUDE.md)

## Localization

`lib/i18n/<locale>.i18n.json`, one file per locale, same keys as `en.i18n.json`
(base locale) — `dart run build_runner build -d` fails on any missing key, so
the set can't drift out of parity. New locales just need a new file; no
config change (`slang.yaml`).

Supported: `en` (base), `nl`, `es`, `fr`. `nl`/`es`/`fr` are machine-translated
and need a native-speaker review before anyone treats their wording as final
— this is a public app, and the rule-explanation and social-copy strings
(game mode descriptions, the "good to know" body text, judging prompts) are
exactly the kind that read stilted without one. Track review sign-off per
locale in an issue against this repo.
