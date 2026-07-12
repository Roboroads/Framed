import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_mode.dart';
import 'lobby_roster_entry.dart';

part 'lobby_snapshot.freezed.dart';

/// The lobby's state at the moment [LobbyRepository.fetchLobby] is called —
/// the baseline [LobbyBloc] then keeps current via realtime events.
@freezed
sealed class LobbySnapshot with _$LobbySnapshot {
  const factory LobbySnapshot({
    required String hostPlayerId,
    required String? joinToken,
    required GameMode mode,
    required int disperseMinutes,
    required int softPunishmentMinutes,
    required int hardPunishmentMinutes,
    required int compassUpdateIntervalMinutes,
    required int compassViewSeconds,
    required int voteTimeoutMinutes,
    required int frameCooldownMinutes,
    required int geofenceRadiusM,
    required List<LobbyRosterEntry> roster,
  }) = _LobbySnapshot;
}
