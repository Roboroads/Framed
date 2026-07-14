import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/push/push_service.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/core/session/session_store.dart';
import 'package:framed/features/lobby/domain/game_settings.dart';
import 'package:framed/features/lobby/domain/lobby_error.dart';
import 'package:framed/features/lobby/domain/lobby_repository.dart';
import 'package:framed/features/lobby/domain/lobby_snapshot.dart';
import 'package:framed/features/lobby/presentation/join/join_cubit.dart';
import 'package:framed/features/lobby/presentation/join/join_state.dart';
import 'package:postgrest/postgrest.dart';

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

class _FakeLobbyRepository implements LobbyRepository {
  String? capturedNameCiphertext;
  String? capturedNameHmac;
  String? capturedPlatform;
  Uint8List? capturedSelfie;
  Object? failure;
  Object? selfieFailure;
  int joinGameCallCount = 0;

  static const gameId = 'game-1';
  static const playerId = 'player-joiner';

  @override
  Future<(String, String)> joinGame({
    required String joinToken,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) async {
    joinGameCallCount++;
    if (failure != null) throw failure!;
    capturedNameCiphertext = nameCiphertext;
    capturedNameHmac = nameHmac;
    capturedPlatform = platform;
    return (gameId, playerId);
  }

  @override
  Future<void> uploadSelfie({
    required String gameId,
    required String playerId,
    required Uint8List encryptedSelfie,
  }) async {
    if (selfieFailure != null) {
      final f = selfieFailure!;
      selfieFailure = null; // fails only once, so a retry can succeed
      throw f;
    }
    capturedSelfie = encryptedSelfie;
  }

  @override
  Future<(String, String)> createGame({
    required GameSettings settings,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) => throw UnimplementedError();

  @override
  Future<String> myHostPlayerId(String gameId) => throw UnimplementedError();

  @override
  Future<void> updateSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) => throw UnimplementedError();

  @override
  Future<void> leaveLobby(String gameId) => throw UnimplementedError();

  @override
  Future<LobbySnapshot> fetchLobby(String gameId) => throw UnimplementedError();

  @override
  Future<void> startGame(String gameId) => throw UnimplementedError();
}

void main() {
  group('JoinCubit', () {
    late _FakeLobbyRepository repository;
    late GameSession session;
    late GameCrypto hostCrypto;
    late Uint8List keyBytes;
    late JoinCubit cubit;

    setUp(() async {
      repository = _FakeLobbyRepository();
      session = GameSession(SessionStore(_FakeSecureKeyValueStore()));
      hostCrypto = await GameCrypto.generate();
      keyBytes = await hostCrypto.keyBytes;
      cubit = JoinCubit(
        repository: repository,
        session: session,
        pushService: PushService(),
        joinToken: 'token-1',
        gameKeyBytes: keyBytes,
      );
    });

    test('canSubmit is false until name and selfie are both set', () {
      expect(cubit.state.canSubmit, isFalse);

      cubit.nameChanged('Bob');
      expect(cubit.state.canSubmit, isFalse);

      cubit.selfieChanged(Uint8List.fromList([1, 2, 3]));
      expect(cubit.state.canSubmit, isTrue);
    });

    test('submit() is a no-op while the form is incomplete', () async {
      await cubit.submit();

      expect(cubit.state.status, JoinStatus.editing);
      expect(session.isActive, isFalse);
    });

    test('happy path: joins, uploads the selfie, starts the session', () async {
      cubit
        ..nameChanged('  Bob ')
        ..selfieChanged(Uint8List.fromList(List.generate(50, (i) => i)));

      await cubit.submit();

      expect(cubit.state.status, JoinStatus.success);
      expect(repository.capturedPlatform, isNotEmpty);

      // The reconstructed key matches the host's — decrypting what the
      // repository received with the host's own crypto returns the input.
      expect(
        await hostCrypto.decryptString(repository.capturedNameCiphertext!),
        'Bob',
      );
      expect(await hostCrypto.nameHmac('bob'), repository.capturedNameHmac);
      final decryptedSelfie = await hostCrypto.decryptBytes(
        repository.capturedSelfie!,
      );
      expect(decryptedSelfie, List.generate(50, (i) => i));

      expect(session.isActive, isTrue);
      expect(session.gameId, _FakeLobbyRepository.gameId);
      expect(session.playerId, _FakeLobbyRepository.playerId);
    });

    test('sad path: name_taken surfaces as LobbyError.nameTaken', () async {
      repository.failure = const PostgrestException(message: 'name_taken');
      cubit
        ..nameChanged('Bob')
        ..selfieChanged(Uint8List.fromList([1, 2, 3]));

      await cubit.submit();

      expect(cubit.state.status, JoinStatus.failure);
      expect(cubit.state.error, LobbyError.nameTaken);
      expect(session.isActive, isFalse);
    });

    test(
      'sad path: an unrecognized error surfaces as LobbyError.unknown',
      () async {
        repository.failure = Exception('network is down');
        cubit
          ..nameChanged('Bob')
          ..selfieChanged(Uint8List.fromList([1, 2, 3]));

        await cubit.submit();

        expect(cubit.state.status, JoinStatus.failure);
        expect(cubit.state.error, LobbyError.unknown);
      },
    );

    test('retry after a failed selfie upload does not re-join (which would '
        'now fail as name_taken against the seat already held)', () async {
      repository.selfieFailure = Exception('upload failed');
      cubit
        ..nameChanged('Bob')
        ..selfieChanged(Uint8List.fromList([1, 2, 3]));

      await cubit.submit();
      expect(cubit.state.status, JoinStatus.failure);
      expect(repository.joinGameCallCount, 1);
      expect(session.isActive, isFalse);

      await cubit.submit();
      expect(cubit.state.status, JoinStatus.success);
      expect(repository.joinGameCallCount, 1);
      expect(session.isActive, isTrue);
    });
  });
}
