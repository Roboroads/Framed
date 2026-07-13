import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The read/write/delete surface [SessionStore] needs — just enough to
/// swap the real OS-backed plugin for an in-memory fake in tests, same
/// reason every repository in this codebase sits behind an interface.
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Persists just enough of [GameSession] to resume after a crash or
/// force-close (#54) — the game id, this device's player id, and the game
/// key. OS-backed secure storage (Keystore/Keychain), not plain prefs: the
/// key is the same E2EE secret the QR hands over, IDEA.md's security
/// section assumes it never sits in recoverable plaintext at rest.
class SessionStore {
  SessionStore([SecureKeyValueStore? store])
    : _store = store ?? const FlutterSecureKeyValueStore();

  final SecureKeyValueStore _store;

  static const _gameIdKey = 'session_game_id';
  static const _playerIdKey = 'session_player_id';
  static const _keyBytesKey = 'session_key_bytes';

  Future<void> save({
    required String gameId,
    required String playerId,
    required Uint8List keyBytes,
  }) async {
    await Future.wait([
      _store.write(_gameIdKey, gameId),
      _store.write(_playerIdKey, playerId),
      _store.write(_keyBytesKey, base64Encode(keyBytes)),
    ]);
  }

  /// Null if nothing is persisted, or if what's there is only partially
  /// written (shouldn't happen — [save] and [clear] each touch all three
  /// keys — but a leftover from an interrupted write is safer to treat as
  /// nothing than as a broken session).
  Future<PersistedSession?> read() async {
    final values = await Future.wait([
      _store.read(_gameIdKey),
      _store.read(_playerIdKey),
      _store.read(_keyBytesKey),
    ]);
    final gameId = values[0];
    final playerId = values[1];
    final keyBytesB64 = values[2];
    if (gameId == null || playerId == null || keyBytesB64 == null) {
      return null;
    }
    return PersistedSession(
      gameId: gameId,
      playerId: playerId,
      keyBytes: base64Decode(keyBytesB64),
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _store.delete(_gameIdKey),
      _store.delete(_playerIdKey),
      _store.delete(_keyBytesKey),
    ]);
  }
}

class PersistedSession {
  const PersistedSession({
    required this.gameId,
    required this.playerId,
    required this.keyBytes,
  });

  final String gameId;
  final String playerId;
  final Uint8List keyBytes;
}
