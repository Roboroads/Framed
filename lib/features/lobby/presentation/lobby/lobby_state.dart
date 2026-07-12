import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';

part 'lobby_state.freezed.dart';

enum LobbyPhase { loading, ready, error }

/// A roster row with its name already decrypted — nothing in the
/// presentation layer ever touches ciphertext directly.
@freezed
sealed class LobbyPlayer with _$LobbyPlayer {
  const factory LobbyPlayer({
    required String id,
    required String name,
    required bool hasSelfie,
  }) = _LobbyPlayer;
}

/// Minimum ready players `start_game` requires (server re-checks this; see
/// backend/volumes/db/init/14-start-tick.sql).
const lobbyMinReadyPlayers = 3;

@freezed
sealed class LobbyState with _$LobbyState {
  const factory LobbyState({
    @Default(LobbyPhase.loading) LobbyPhase phase,
    @Default(<LobbyPlayer>[]) List<LobbyPlayer> roster,
    String? hostPlayerId,
    String? joinToken,
    @Default(GameMode.mostFrames) GameMode mode,
    @Default(10) int disperseMinutes,
    @Default(2) int softPunishmentMinutes,
    @Default(5) int hardPunishmentMinutes,
    @Default(10) int compassUpdateIntervalMinutes,
    @Default(30) int compassViewSeconds,
    @Default(5) int voteTimeoutMinutes,
    @Default(5) int frameCooldownMinutes,
    @Default(200) int geofenceRadiusM,
    @Default(false) bool starting,
    LobbyError? error,
    DateTime? dispersalEndsAt,
  }) = _LobbyState;

  const LobbyState._();

  int get readyCount => roster.where((p) => p.hasSelfie).length;

  bool get canStart => readyCount >= lobbyMinReadyPlayers && !starting;
}
