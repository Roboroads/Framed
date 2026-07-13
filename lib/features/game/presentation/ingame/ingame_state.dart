import 'package:freezed_annotation/freezed_annotation.dart';

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
  const factory IngameFrameStatus.cooldown({required DateTime until}) =
      FrameCooldown;
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
    IngameCompass? compass,
    IngameTargetLocation? targetLocation,
    @Default(IngameFrameStatus.ready()) IngameFrameStatus frameStatus,
    // Oldest first (#22) — only the front is ever shown or loaded; queued
    // behind it just means another assassin's frame is already pending.
    @Default([]) List<IngameJudgingEntry> judgingQueue,
  }) = _IngameState;
}
