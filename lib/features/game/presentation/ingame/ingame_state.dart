import 'package:freezed_annotation/freezed_annotation.dart';

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

@freezed
sealed class IngameState with _$IngameState {
  const factory IngameState({
    required IngamePhase phase,
    IngameWarning? warning,
    IngameCompass? compass,
    IngameTargetLocation? targetLocation,
  }) = _IngameState;
}
