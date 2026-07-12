import 'dart:typed_data';

import 'game_settings.dart';

/// The lobby lifecycle RPCs (backend/volumes/db/init/13-lobby.sql), plus the
/// selfie upload that goes with them. One shared interface for the host flow
/// (#8), join flow (#9), and lobby screen (#10) — errors surface as
/// [LobbyError] via the caller catching and mapping the thrown exception.
abstract interface class LobbyRepository {
  /// Creates the game and the host's own player row. Returns
  /// `(gameId, joinToken)`.
  Future<(String gameId, String joinToken)> createGame({
    required GameSettings settings,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  });

  /// Resolves a join token and seats the caller. Returns
  /// `(gameId, playerId)`.
  Future<(String gameId, String playerId)> joinGame({
    required String joinToken,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  });

  Future<void> updateSettings({
    required String gameId,
    required GameSettings settings,
  });

  Future<void> leaveLobby(String gameId);

  /// The host's own player id in [gameId] — used right after [createGame],
  /// which does not return it directly. Not for the joining side:
  /// [joinGame] already returns its caller's player id.
  Future<String> myHostPlayerId(String gameId);

  /// Uploads the already-encrypted selfie to its canonical path and records
  /// it via `set_selfie`.
  Future<void> uploadSelfie({
    required String gameId,
    required String playerId,
    required Uint8List encryptedSelfie,
  });
}
