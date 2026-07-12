import '../crypto/game_crypto.dart';

/// The running game, from the moment a player is seated until it ends.
///
/// The one place later features (lobby roster, ingame, judging, ...) read
/// the game id, this device's player id, and the game key from. Set once,
/// either by the host flow (create_game) or the join flow (join_game).
class GameSession {
  String? _gameId;
  String? _playerId;
  GameCrypto? _crypto;

  String get gameId => _gameId!;
  String get playerId => _playerId!;
  GameCrypto get crypto => _crypto!;

  bool get isActive => _gameId != null;

  void begin({
    required String gameId,
    required String playerId,
    required GameCrypto crypto,
  }) {
    _gameId = gameId;
    _playerId = playerId;
    _crypto = crypto;
  }

  /// Called when the game ends or is left — the key and ids must not
  /// outlive the session (see IDEA.md "Cleanup").
  void end() {
    _gameId = null;
    _playerId = null;
    _crypto = null;
  }
}
