# Release checklist

Store submission blockers, not a general pre-flight list — `dart format .`, `flutter analyze`, and `flutter test` already gate every commit (CLAUDE.md).

## Privacy policy (#30)

- [ ] `docs/privacy-policy/index.html` loads at `https://getframed.fun/privacy-policy` (needs #66's DNS/Pages wiring live first).
- [ ] No `FIXME` text remains on the policy page:
  - [ ] Hosting section names the real provider and region (must be EU, per the policy's own claim).
  - [ ] Contact section confirms the right contact point / legal entity name for data-subject requests.
- [ ] Policy URL is entered in both the Play Console and App Store Connect listings.
- [ ] Pre-join consent copy (`lib/i18n/*.i18n.json`, `preJoin.consentNotice`) still says the same things as the policy page — re-check after any change to either.
- [ ] Policy statements are still true against the implementation (retention: `backend/README.md` "Cleanup and retention"; E2EE fields: `lib/core/crypto/game_crypto.dart` call sites; push payload shape: `backend/volumes/functions/push/index.ts`) — re-check after any change that touches what's collected, encrypted, or retained.

## UGC / content moderation stance

Frame photos are user-submitted and could catch bystanders (see the policy's "Bystanders" section). Neither store has asked for a report/block mechanism yet. If a store review does:

- [ ] The documented fallback (IDEA.md) is a minimal "report photo" button on the judging screen — implement as its own issue, don't block this checklist on building it speculatively.

## Store listing basics

- [ ] App icon, screenshots, and description ready (tracked separately, #47).
- [ ] Real device validation done (#31): background location survives a locked screen, push actually arrives.
