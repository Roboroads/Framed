import '../crypto/game_crypto.dart';
import 'session_store.dart';

/// The running game, from the moment a player is seated until it ends.
///
/// The one place later features (lobby roster, ingame, judging, ...) read
/// the game id, this device's player id, and the game key from. Set once,
/// either by the host flow (create_game) or the join flow (join_game).
class GameSession {
  GameSession(this._store);

  final SessionStore _store;

  String? _gameId;
  String? _playerId;
  GameCrypto? _crypto;

  String get gameId => _gameId!;
  String get playerId => _playerId!;
  GameCrypto get crypto => _crypto!;

  bool get isActive => _gameId != null;

  /// Persists alongside setting in-memory state (#54) — a crash or
  /// force-close must be able to find this again. A persistence failure
  /// (e.g. a broken platform keystore) shouldn't block actually playing —
  /// it just means this device can't resume after a crash, same as before
  /// this feature existed.
  Future<void> begin({
    required String gameId,
    required String playerId,
    required GameCrypto crypto,
  }) async {
    _gameId = gameId;
    _playerId = playerId;
    _crypto = crypto;
    try {
      await _store.save(
        gameId: gameId,
        playerId: playerId,
        keyBytes: await crypto.keyBytes,
      );
    } catch (e) {
      // Debug-only: see the matching note in SessionResumeService.resume.
      assert(() {
        // ignore: avoid_print
        print('SESSION_DEBUG: save failed: $e');
        return true;
      }());
    }
  }

  /// Called when the game ends or is left — the key and ids must not
  /// outlive the session (see IDEA.md "Cleanup").
  Future<void> end() async {
    _gameId = null;
    _playerId = null;
    _crypto = null;
    await _store.clear();
  }
}
