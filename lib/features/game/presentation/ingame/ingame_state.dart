import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/chat/chat_message.dart';
import '../../../../core/realtime/game_event.dart';
import '../../domain/judging_frame.dart';
import '../../domain/target.dart';

part 'ingame_state.freezed.dart';

/// The ingame screen's phase (#11). Later issues add more overlay flags to
/// [IngameState] (pending frame, compass snapshot, judging queue) alongside
/// [phase] rather than new blocs — see IDEA.md "Screens" (ingame).
@freezed
sealed class IngamePhase with _$IngamePhase {
  /// Dispersing: waiting for `target_assigned`. [endsAt] is authoritative
  /// server time; any on-screen countdown is cosmetic.
  const factory IngamePhase.dispersing({required DateTime endsAt}) =
      IngameDispersing;

  const factory IngamePhase.playing({required Target target}) = IngamePlaying;

  /// The target's name/selfie failed to decrypt or download — surfaced
  /// instead of crashing the screen.
  const factory IngamePhase.targetLoadFailed() = IngameTargetLoadFailed;

  /// This player is out (#54's reconnect catch-up can land here directly
  /// on cold start). [photoBytes] is the decrypted frame that killed you —
  /// only present for `cause == 'framed'`; `mia` has no photo, no assassin
  /// (#23).
  const factory IngamePhase.dead({
    required String cause,
    String? killerName,
    required int survivedSeconds,
    Uint8List? photoBytes,
  }) = IngameDead;
}

/// A rule-break in progress (#12/#13's `warning` event, active branch).
@freezed
sealed class IngameWarning with _$IngameWarning {
  const factory IngameWarning({
    required List<String> reasons,
    required DateTime hardDeadline,
  }) = _IngameWarning;
}

/// The current compass pulse snapshot (#16), valid until [expiresAt].
/// [receivedAt] is stamped locally (not sent by the server) purely so the
/// UI can render a countdown progress bar for the remaining view time.
@freezed
sealed class IngameCompass with _$IngameCompass {
  const factory IngameCompass({
    required double bearingDeg,
    required double distanceM,
    required DateTime expiresAt,
    required DateTime receivedAt,
  }) = _IngameCompass;
}

/// The target's exact location while soft-punished (#13, #18).
@freezed
sealed class IngameTargetLocation with _$IngameTargetLocation {
  const factory IngameTargetLocation({
    required double lat,
    required double lng,
  }) = _IngameTargetLocation;
}

/// The frame button's state (#21). [cooldown]'s [until] mirrors the
/// server's `frame_cooldown_until` — no local logic decides when it ends.
@freezed
sealed class IngameFrameStatus with _$IngameFrameStatus {
  const factory IngameFrameStatus.ready() = FrameReady;
  const factory IngameFrameStatus.waitingForVerdict() = FrameWaitingForVerdict;
  // reason (#86) is the server's frame_verdict.reason verbatim ('rejected'
  // or 'timeout') — null only for a resume/catch-up path that doesn't
  // carry it, not a real third outcome.
  const factory IngameFrameStatus.cooldown({
    required DateTime until,
    String? reason,
  }) = FrameCooldown;
}

/// One entry in the judging queue (#22). Holds the raw event fields so a
/// failed or not-yet-attempted load can be (re)started without asking the
/// server again — only [loaded] and [failed] change as that happens.
@freezed
sealed class IngameJudgingEntry with _$IngameJudgingEntry {
  const factory IngameJudgingEntry({
    required String frameId,
    required String photoPath,
    required String targetNameCiphertext,
    required String targetSelfiePath,
    JudgingFrame? loaded,
    @Default(false) bool failed,
  }) = _IngameJudgingEntry;
}

@freezed
sealed class IngameState with _$IngameState {
  const factory IngameState({
    required IngamePhase phase,
    IngameWarning? warning,
    // Still inside the geofence but close to its edge (#61) — a heads-up
    // distinct from [warning], which only starts once a player has
    // actually left (or gone stale) and a punishment clock is running.
    @Default(false) bool nearGeofenceEdge,
    IngameCompass? compass,
    // The game's next scheduled compass pulse (#73) — set once the game
    // goes active (get_my_state) and refreshed on every pulse received,
    // so the compass panel can count down to it while [compass] is null
    // instead of showing a static "soon".
    DateTime? nextPulseAt,
    // This player's own decrypted name (#73) — resolved from the roster,
    // same as dead chat resolves sender names. Null until that resolves.
    String? myName,
    IngameTargetLocation? targetLocation,
    @Default(IngameFrameStatus.ready()) IngameFrameStatus frameStatus,
    // Oldest first (#22) — only the front is ever shown or loaded; queued
    // behind it just means another assassin's frame is already pending.
    @Default([]) List<IngameJudgingEntry> judgingQueue,
    // Oldest first (#24), history + live merged. Only populated once this
    // player is dead — see IngameBloc._startDeadChat.
    @Default([]) List<ChatMessage> deadChat,
    // Screen-stays-on toggle (#78). Defaults on: a locked/dimmed screen is
    // how a compass pulse or warning gets missed while playing outside.
    @Default(true) bool keepAwake,
    // Everyone else currently dead (#80), oldest death first, resolved
    // once when this player's own death phase starts — a one-time
    // snapshot, not live-updated, same as the roster fetch dead chat
    // already does for sender names.
    @Default([]) List<String> otherDeadPlayerNames,
    // Set only by the get_my_state catch-up (#89) discovering the game
    // already finished — the live broadcast path (game:{game_id}) still
    // navigates directly from IngamePage, bypassing bloc state entirely.
    // This is the backstop for a channel that went stale before that
    // broadcast ever arrived (same class of gap get_my_state exists to
    // close for every other phase).
    GameFinished? pendingFinish,
  }) = _IngameState;
}
