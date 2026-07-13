# Framed

A local-area circular assassination game you play IRL.

## How does the game work

This is a game played in real life, assisted by your phone's GPS. Players gather at a starting point and start a game, after which they have to disperse. After the dispersion timer, the game starts for real. Everyone gets a target they have to find and "frame" by taking a picture of them. The picture is sent to the other players to judge whether it really shows the target. On a majority "yes" vote, the target is out of the game and the assassin inherits their target's target. The game ends when one player remains; who wins depends on the game mode.

- **Players:** 3 or more, no upper limit. (With 3 players there is exactly 1 judge per frame; that single vote decides.)
- **The host** is a regular player once the game starts. The server is authoritative — the game continues even if the host's phone dies. No kick/force-end powers in-game.

## Game modes

The host picks one of two modes in the lobby. Gameplay is identical in both — same circle, frames, votes, permanent deaths, punishments. Only the winner differs:

- **Most frames wins** (default). When the game ends, the player with the most confirmed frames wins — a dead player can win. Ties break on survival time, so the last player standing beats anyone tied with them.
- **Last man standing.** The last player alive wins.

Either way the game ends when one player remains (or when the last players die MIA simultaneously).

## Core loop: framing & judging

1. Assassin opens the in-app camera from the ingame screen and photographs their target. **In-app camera only** — no gallery uploads.
2. The photo goes to all other players (alive **and** dead) except the assassin and the target. Judges see the frame photo **side by side with the target's reference selfie**: "Is this (player name)?" with ✗ / ✓ buttons.
3. The vote resolves the moment a **mathematical majority of all judges** is reached (e.g. 4 of 6 said yes — remaining votes can't change the outcome). Fallback: after `vote_timeout_minutes` the majority of votes actually cast decides. Tie or zero votes = frame fails.
4. **Vote passes:** target dies, assassin inherits the target's target and gets a fresh compass update for them.
5. **Vote fails:** the assassin gets a frame cooldown (`frame_cooldown_minutes`) before they can submit another photo. Nothing else happens — the target is not informed.

While a vote about them is pending, the target is **not notified** and keeps playing normally — but any frame *they* submit during that window is held until their own verdict resolves (the dead can't kill). Only one pending frame per assassin at a time.

## The compass

Once every `compass_update_interval_minutes` a **global pulse** fires: every alive player simultaneously receives a compass update — an arrow and distance to their target's location *at pulse time* (a snapshot; it does not track the target live). The arrow rotates live with the device compass. The update disappears after `compass_view_seconds` seconds.

The simultaneous pulse is a feature: everyone stops to check their phone at the same moment, which is itself a tell you can watch for IRL.

## Notifications

Anything that needs your attention fires a **high-priority, time-sensitive push notification** (on both platforms), so the game works with your phone in your pocket:

- Dispersal over — the game has started, here is your target.
- Compass pulse available (time-limited: it disappears after `compass_view_seconds`).
- New frame photo to judge.
- Verdict on your submitted frame (kill confirmed / rejected + cooldown).
- Rule-break warning (geofence, stale location) and punishment escalation.
- You died / new target inherited / game finished.

## Tech used

- "Clean architecture" for the app architecture.
- Backend is a self-hosted Supabase (+ PostGIS) on an EU server.
- End-to-end encryption of game content the server doesn't need (photos, names, chat) with a per-game key — see Security. Locations stay readable server-side: the server needs them for authority (geofence, compass, punishments).
- State management with flutter_bloc, freezed union types for state classes.
- I18n with `slang`.
- A background service for sending location updates, so the game keeps working while the phone is locked or the app is backgrounded.
- Targets both Android and iOS.

### Git

- The project is hosted open source on GitHub. Repository is Roboroads/Framed.
- Commits using conventional commits.

## Screens

- **Home screen.** Two buttons: join game and host game. Join game opens a camera to scan the QR code on the host's screen. Also shows the "play fair" disclaimer: this game trusts the group — we don't detect GPS spoofing or modified clients, so just don't do that.
- **Pre-join.** The player fills in their name and takes a selfie for reference (used by judges during votes). Names must be unique within the lobby ("Is this Bob?" breaks with two Bobs) — duplicates are rejected here.
- **Lobby.** The host sets up game settings and shows a QR code so others can join.
- **Ingame.** This screen has multiple states:
  - **Disperse!** A countdown timer until you get your target.
  - **Game in progress.** Shows the name + reference picture of your target, and a "frame" button that opens the in-app camera. At every global pulse the compass update appears (arrow + distance, live device-compass rotation) and disappears after `compass_view_seconds`. If your target is soft-punished for leaving the play area, a map with their exact location appears here.
  - **Judging modal.** Frame photo next to the target's reference selfie, title "Is this (player name)?", ✗ and ✓ buttons.
  - **Warning modal.** Shown while you're breaking a rule (e.g. outside the geofence) until you stop or die.
  - **Play-area edge banner.** A small, dismissable-by-nature banner (not a modal, doesn't block anything) while you're still inside the geofence but close to its edge — a heads-up before the warning modal above would ever trigger.
  - **My location.** A button (available during disperse and game in progress) opens a full-screen map showing your own live position against the play-area boundary — distinct from the target's soft-punishment map above, which is about someone else's location, not your own.
- **Death screen.** How you died, how long you survived, the photo that framed you, and **who your assassin was**. Includes a chat with the other dead players so they can set up a meeting spot. Dead players still receive judging modals.
- **Game finish.** Winner (per the game mode, with the mode named on screen) plus stats (most kills, most stand-still player, most moved player, combined movement, etc.) and the full kill chain. The host can choose "replay with same players" (same lobby, same selfies, reshuffled targets); players can only "Leave game".

## Game options

Set by the host in the lobby:

- `game_mode` — `most_frames` (default) or `last_man_standing`. See Game modes.
- `geofence_center` and `geofence_radius` — the play area for this game.
- `disperse_minutes` — dispersal time before the game starts. Default: 10.
- `soft_punishment_minutes` — how long you can break a rule before soft consequences. Default: 2.
- `hard_punishment_minutes` — how long you can break a rule before you die automatically. You die as if framed, but the death screen shows "MIA (broke a game rule for too long)". Default: 5.
- `compass_update_interval_minutes` — interval of the global compass pulse. Default: 10.
- `compass_view_seconds` — seconds a compass update stays visible. Default: 30.
- `vote_timeout_minutes` — max time a vote stays open before it resolves on cast votes. Default: 5.
- `frame_cooldown_minutes` — cooldown after a failed frame. Default: 5.

## Game rules

- **Stay inside the play area.**
  - The server checks this (PostGIS) against the game's geofence and runs the punishment timers.
  - While breaking this rule you receive no compass updates for your target.
  - Soft punishment: your assassin receives your exact location on the map.
  - Hard punishment: MIA death.
  - Proactive edge nudge: while still *inside* the geofence but within 5% of `geofence_radius_m` of the boundary, the app shows a lightweight, non-blocking heads-up — a chance to step back in before you'd actually trigger the rule above. This is not a punishment and starts no timer; it clears the moment you move back toward center or actually cross the boundary (at which point the rule above takes over instead).
- **Your phone must send location updates to the server.**
  - The app sends a location update every 30 seconds. You count as **stale** when the server hasn't received one for 90 seconds (3 missed updates — tolerates a bad GPS fix or a short network drop).
  - While stale: the warning modal shows, and you receive no compass update at a pulse. Your assassin's compass still points at your last known location.
  - Stale for `hard_punishment_minutes` straight → MIA death (this covers dead phones and force-closed apps). Any successful update resets the timer.
  - There is no mid-game quit. Reopening the app after a crash or force-close resumes exactly where you left off (#54) — the app itself doesn't kill you. But nothing pauses the staleness clock while you're gone, so silence for `hard_punishment_minutes` still kills you as MIA whether that silence is a crash, a dead phone, or someone deliberately sitting out. Reconnecting only saves you if you're back before that timer runs out.
  - This rule binds the living only. Once dead you may close the app freely — you just stop judging and chatting.
- **You must vote on pending frames.**
  - While you have an unvoted frame open, you receive no compass update at a pulse. Lazy judges lose their own intel.
- **Votes are final.**
  - A majority "yes" kills the target even if the judges were wrong. There is no appeal; the vote is the truth.
- **Dispersal phase.**
  - Location updates and geofence enforcement start at game start, not after dispersal.
  - Framing is impossible until dispersal ends and you receive your target.

### Safety rules

The app can't enforce these; they're shown at pre-join alongside the play-fair disclaimer:

- Watch for traffic — no framing across a road.
- No trespassing; stay out of private property.
- No physical contact: this is a photo game, never a tag game.
- Don't photograph bystanders up close; aim at your target.
- Respect any areas the host declares off-limits.

## Edge cases

- **Final duel (2 alive):** both players target each other; the dead are the jury.
- **Target killed by someone else while a frame on them is pending:** impossible — each player has exactly one assassin in the circle.
- **Assassin dies via MIA while their frame is pending:** the pending vote is cancelled.
- **Simultaneous pending frames** (A framed B while B's frame of C is pending): B's held frame resolves after B's own verdict — if B dies, B's frame is void.
- **App reinstall mid-game:** unlike a crash or force-close, a reinstall wipes the game key and session with the rest of the app's local data — genuinely unrecoverable. You cannot rejoin. The staleness path makes you MIA.
- **App crash/close before the lobby, or leaving on purpose:** rescan the host's QR to get your seat back — same join flow, same name, no new player row. Only works while the game is still in the lobby; once it starts the join token is gone (#54).
- **Host leaves the lobby:** the lobby stays open; the host role (settings + start button) transfers to the longest-joined player.

## Security

Data from the backend is strictly need-to-know. You cannot list lobbies; the QR code carries the join token (random, high-entropy, invalid once the game starts) **and the game encryption key** — the key never reaches the server. Players only receive location updates for the player they are targeting — never everyone. Frame photos go only to judges. The reference selfie is only shown to judges during a vote.

- **Trust model: play fair.** The game is local, played with people you know. We don't detect GPS spoofing or modified clients — the home screen carries a "just play fair" disclaimer instead.
- **Server is game master.** All game state (the target circle, locations, votes, cooldowns, deaths, punishment timers) lives on and is enforced by the server; clients only display state and events they receive. Game *content* the server doesn't need for authority (photos, names, chat) is end-to-end encrypted — the server routes those blobs without being able to read them. A cheater can lie about their location or photo, but never skip a vote or resurrect themselves.
- **Storage security.** Photos live in private Supabase Storage buckets, served via short-lived signed URLs only to the players who need them. No public buckets. (Defense in depth — the blobs are E2E-encrypted anyway.)
- **Cleanup.** After a game, all information (pictures, game data) is deleted. "Replay with same players" carries the lobby (names, selfies) into the next game — deletion happens when the lobby disbands. Games running longer than 24 hours are auto-cleaned the same way; we keep an anonymous counter of how often this triggers. Nothing else is kept except stats that cannot be traced back to players or locations, for "fun stats" purposes (how much the game gets played, how long, etc.).

### End-to-end encryption

Rule of thumb: **if server authority needs it, it's not encrypted.** Everything else is unreadable to the server host. Scheme:

- **One symmetric game key** (AES-GCM), generated by the host's device, distributed only via the QR code. It never touches the server. Every player in the game holds the same key — need-to-know *within* the game is enforced by server routing (who receives which blob), which matches the play-fair trust model.
- **Encrypted client-side before upload:** display names, reference selfies, frame photos, and dead-chat messages. The server stores and relays opaque blobs.
- **Not encrypted — the server needs authority over it:** location updates. The server uses them for geofence enforcement (PostGIS), compass pulses, staleness, and punishments. Locations are still ephemeral: only last-known is stored, deleted with the rest of the game data.
- **Push notifications are data-only:** the payload wakes the app, which decrypts locally and renders the notification on-device. Names and photos never pass through APNs/FCM in readable form.
- **Replay with same players:** the host's device generates a fresh game key and distributes it encrypted under the old key — no QR re-scan needed.

Upgrade path if the trust model ever changes (public lobbies): per-player keypairs with pairwise sealed boxes.

## Privacy & GDPR

The delete-everything design is the core of compliance, but these points need to be explicit:

- **What we process:** display name, reference selfie, live GPS location, frame photos, push token, dead-chat messages. All of it is personal data (faces + location are sensitive), all of it is ephemeral: deleted at game end or by the 24-hour auto-cleanup, whichever comes first. Names, selfies, photos, and chat are end-to-end encrypted — the server operator cannot read them even while they exist. Locations are readable server-side (the server enforces the game with them) but only last-known is stored.
- **Lawful basis:** consent. The pre-join screen states plainly what is collected and how long it lives, before the selfie is taken. Joining a game is the consent action. Leaving the lobby before game start deletes your data immediately; quitting mid-game makes you MIA and everything is wiped at game end (24h max) — the right to erasure, automated.
- **Data minimization:** need-to-know routing is not just security, it's a GDPR argument — no player, and no query, receives more than the game requires. Only last-known location is stored, never a movement history (MVP). Movement stats (most moved, most stand-still, combined movement) are running per-player totals updated on each location update — counters, not tracks.
- **Hosting:** self-hosted Supabase on an EU server — data never leaves the EU, and there is no third-party processor to list beyond the hosting provider (name them and their region in the privacy policy). Thanks to E2EE, even that provider only ever holds ciphertext.
- **No tracking:** no accounts, no ads, no third-party analytics. The retained "fun stats" are aggregate and anonymous (game count, duration, player counts) with no IDs, names, or locations.
- **Bystanders:** frame photos may catch non-players. The privacy policy and the play-fair disclaimer should tell players to photograph the target, not crowds; the 24h-max retention limits the harm.
- **Store requirement:** both app stores require a hosted privacy policy URL — write it from the points above before the first release.

## Non-MVP

Elements to take into account for later:

- **More game modes.** The MVP ships most-frames and last-man-standing; later Free-For-All or teams.
- **Powerups.** Shown on the map; claim one by standing at that spot (landmark?) and use it from the ingame screen. Powerups should be individually toggleable per-game. Candidate set: 
  - Cloak (your location is skipped in one pulse)
  - Compass (an extra personal compass peek)
  - Radar (you get a compass hint for where your assassin is)
  - Hourglass (shows exact location of target 15 minutes ago, target gets notified)
  - Spyglass (Tells you who your assassin is, assassin gets notified)
- **Shrinking geofence.** The play area shrinks over time or when few players remain, so the endgame can't stall on two careful players never meeting.
- **Bounty system.** The longest-surviving or most-camping player gets marked; everyone receives a compass hint to them at the next pulse.
- **Spectator map for the dead.** Dead players see a live map with everyone's position plus the kill feed, turning the death screen + chat into a spectator lounge.
- **Kill feed announcements.** Anonymous broadcasts to all players: "A player has been framed. 6 remain."
- **End-of-game replay map.** An animated timeline of all movement and kills on the finish screen, shown once before the privacy wipe deletes the data.
- **Public lobbies.** Find public games in your neighborhood. The MVP is deliberately local-only (you trust who you play with); public games change the trust model and would need the anti-cheat and moderation story the MVP skips.

## Known risks

- Background location permission UX: both platforms make "always allow" a hostile flow, and iOS background location + camera wakeups need real-device validation early.
- Battery drain from continuous GPS + background service — the 30-second update interval needs real-device validation.
- Store review may still classify frame photos + chat as user-generated content and require a report/block mechanism, ephemeral or not. If review pushes back, a minimal "report photo" button (flag + instant delete) satisfies it.
