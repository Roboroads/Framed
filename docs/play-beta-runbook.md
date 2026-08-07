# Play Store beta runbook

One-time setup to get CI (`.github/workflows/internal-release.yml` and `release.yml`, issue #33/#34) uploading to the Play internal testing track, plus the per-release routine. Every step here is manual on purpose: it involves accounts and secrets that stay with Robbin and never enter the repo or an AI session.

The workflows already do the rest — once the secrets below exist, every push to main builds a signed bundle against the production backend and uploads it to the internal track, and a `v*` tag additionally publishes a GitHub Release.

## 1. Upload keystore

Play App Signing (default for new apps) means Google holds the key that signs what users install. The keystore generated here is only the *upload key* CI signs bundles with; Play can reset it via support if it's ever lost, so this is low-stakes.

```sh
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -alias upload -keyalg RSA -keysize 4096 -validity 10000
```

Store the `.jks` and both passwords in the password manager, then:

```sh
gh secret set ANDROID_KEYSTORE_BASE64 --repo Roboroads/Framed --body "$(base64 -w0 upload-keystore.jks)"
gh variable set ANDROID_KEY_ALIAS --repo Roboroads/Framed --body "upload"
gh secret set ANDROID_STORE_PASSWORD --repo Roboroads/Framed   # paste when prompted
gh secret set ANDROID_KEY_PASSWORD --repo Roboroads/Framed
```

## 2. Production backend

Both are variables, not secrets: the URL is public knowledge, and Supabase's anon key is public-by-design — it ships inside every build, security comes from RLS. The key's value lives in the prod server's `backend/.env` (`ANON_KEY`).

```sh
gh variable set PROD_SUPABASE_URL --repo Roboroads/Framed --body "https://game.getframed.fun"
gh variable set PROD_SUPABASE_ANON_KEY --repo Roboroads/Framed --body "<ANON_KEY from the prod .env>"
```

## 3. Firebase (push)

Without this, builds still work — `PushService` degrades to "no push", but testers with a locked phone miss compass pulses and MIA warnings, which is most of the game outdoors.

1. [console.firebase.google.com](https://console.firebase.google.com) > create project (analytics off — the app ships none by policy).
2. Add an Android app with package name `me.roboroads.framed`, download `google-services.json`.
3. App side: `gh variable set GOOGLE_SERVICES_JSON --repo Roboroads/Framed < google-services.json` — a variable, not a secret: every value in the file ships inside the APK anyway, and a variable stays viewable/editable in the repo settings. For a local build with push, drop the same file at `android/app/google-services.json` (gitignored so the public repo never carries a copy).
4. Server side: project settings > Service accounts > Generate new private key. Put the JSON in the prod server's env as `FCM_SERVICE_ACCOUNT_JSON` for the functions container (`backend/volumes/functions/push/index.ts` reads it), then restart that container.

iOS later reuses all of this: add an iOS app to the same Firebase project, then `gh variable set GOOGLE_SERVICE_INFO_PLIST --repo Roboroads/Framed < GoogleService-Info.plist` — CI writes it to `ios/Runner/` (gitignored locally, same as the Android file). Two loose ends before iOS push works: the file still has to be added to the Runner target in Xcode (needs a Mac; the whole iOS job is unverified), and the APNs `.p8` auth key goes in the Firebase console (project settings > Cloud Messaging). The server needs nothing extra — FCM relays to APNs, and the push function already sends the iOS background-push fields on every message.

## 4. Play Console

1. Create the app (name Framed, app id `me.roboroads.framed`, free, app not game category is fine either way). Accept Play App Signing.
2. **First upload is manual** — the Play API refuses to create the very first release. Build locally with the prod defines and the keystore from step 1 (copy `android/key.properties.example` to `android/key.properties` and fill it in):

   ```sh
   flutter build appbundle --release \
     --dart-define=SUPABASE_URL=https://game.getframed.fun \
     --dart-define=SUPABASE_ANON_KEY=<anon key>
   ```

   Upload `build/app/outputs/bundle/release/app-release.aab` under Testing > Internal testing > Create release.
3. Testers: Internal testing > Testers > create an email list, share the opt-in link.
4. Service account for CI uploads: in Google Cloud console (any project, the Firebase one from step 3 works), create a service account, generate a JSON key. In Play Console > Users and permissions, invite the service account's email with the *Release to testing tracks* + *View app information* permissions for Framed. Then `gh secret set PLAY_SERVICE_ACCOUNT_JSON --repo Roboroads/Framed < service-account.json`.

### App content declarations (required before any rollout)

- Privacy policy URL: `https://getframed.fun/privacy-policy` (checklist item in `release-checklist.md`).
- Ads: none. App access: no login, but note games need a second phone to try — "all functionality is available without special access" is accurate; a reviewer can host a lobby.
- Content rating questionnaire: no violence-against-realistic-people content (the "assassination" is taking a photo), no gambling, **yes** to sharing user location with other users (the compass/reveal mechanics).
- Target audience: 18+ is the safe pick given real-world location sharing between players; 13+ requires more scrutiny.
- Data safety, drafted from the privacy policy (re-verify against it before submitting):
  - Location (precise + approximate): collected, shared with other players in-game (bearing/distance pulses, punishment reveals), encrypted in transit, deleted at game end / within 24h, required for core functionality, not used for ads or tracking.
  - Personal info (display name) and Photos (selfie, frame photos): collected, end-to-end encrypted (the server stores ciphertext it cannot read; the key travels only in the lobby QR), deleted at game end / within 24h.
  - Device IDs: a push token per game, deleted with the game.
  - No third-party sharing, no analytics or crash-reporting SDKs.

### Store listing

Short/full description, at least 2 phone screenshots, the 512px icon (from `tools/gen_brand.py` output), and a 1024x500 feature graphic. Screenshots need a real device or emulator — still open on the release checklist (#47/#31).

## 5. Cutting a beta release

```sh
git tag v0.2.0 && git push origin v0.2.0
```

`release.yml` builds, uploads to internal testing, and publishes a GitHub Release with the APK. Every push to main keeps the track fresh in between (doc-only pushes skip the build). Promotion beyond internal testing (closed beta, production) stays a manual Play Console action on purpose.

Version code is minutes-since-epoch, monotonic across push and tagged runs — never set it by hand. Version *name* comes from the tag; keep `pubspec.yaml`'s `version:` roughly in sync for local builds.

## Secrets and variables inventory

One rule decides which is which: key material, passwords, and billable credentials are **secrets**; values already public in the shipped artifact, or plain names, are **variables** (viewable and editable in the repo settings).

| Name | Kind | Source |
| --- | --- | --- |
| `ANDROID_KEYSTORE_BASE64` | secret | step 1, `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEY_PASSWORD` / `ANDROID_STORE_PASSWORD` | secret | step 1 |
| `ANDROID_KEY_ALIAS` | variable | step 1, just a name |
| `PROD_SUPABASE_URL` | variable | `https://game.getframed.fun` |
| `PROD_SUPABASE_ANON_KEY` | variable | prod server `backend/.env` (public-by-design client key) |
| `GOOGLE_SERVICES_JSON` | variable | Firebase console (optional; no push without it) |
| `PLAY_SERVICE_ACCOUNT_JSON` | secret | Google Cloud + Play Console invite |
| `TILE_URL_TEMPLATE` | secret | optional; a paid template embeds a billable key. Unset means OSM's volunteer server (beta only) |
| Prod server env `FCM_SERVICE_ACCOUNT_JSON` | server env | Firebase service account key (never on GitHub) |

iOS additions for later (`IOS_*`, `APPSTORE_*`) are classified the same way in `internal-release.yml`'s header: certificate + App Store Connect key stay secrets, the team id, profile name, and provisioning profile are variables.
