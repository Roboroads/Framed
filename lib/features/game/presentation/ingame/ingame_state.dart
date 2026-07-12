import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/target.dart';

part 'ingame_state.freezed.dart';

/// The ingame screen's state machine (#11). Later issues add overlay flags
/// here (warning, pending frame, compass snapshot, judging queue) rather
/// than new blocs — see IDEA.md "Screens" (ingame).
@freezed
sealed class IngameState with _$IngameState {
  /// Dispersing: waiting for `target_assigned`. [endsAt] is authoritative
  /// server time; any on-screen countdown is cosmetic.
  const factory IngameState.dispersing({required DateTime endsAt}) =
      IngameDispersing;

  const factory IngameState.playing({required Target target}) = IngamePlaying;

  /// The target's name/selfie failed to decrypt or download — surfaced
  /// instead of crashing the screen.
  const factory IngameState.targetLoadFailed() = IngameTargetLoadFailed;
}
