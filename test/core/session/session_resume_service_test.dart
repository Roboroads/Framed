import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/core/session/resume_outcome.dart';
import 'package:framed/core/session/session_resume_service.dart';
import 'package:framed/core/session/session_store.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:framed/features/game/domain/geofence_info.dart';

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

class _FakeGameRepository implements GameRepository {
  MyStateResult? myState;
  Object? myStateFailure;

  @override
  Future<MyStateResult> getMyState(String gameId) async {
    if (myStateFailure != null) throw myStateFailure!;
    return myState!;
  }

  @override
  Future<Uint8List> downloadSelfie(String path) => throw UnimplementedError();

  @override
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  }) => throw UnimplementedError();

  @override
  Future<GeofenceInfo> getGeofence(String gameId) => throw UnimplementedError();

  @override
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  }) => throw UnimplementedError();

  @override
  Future<void> submitFrame({
    required String gameId,
    required String photoPath,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List> downloadFramePhoto(String path) =>
      throw UnimplementedError();

  @override
  Future<void> castVote({required String frameId, required bool vote}) =>
      throw UnimplementedError();

  @override
  Future<Map<String, String>> getRoster(String gameId) =>
      throw UnimplementedError();

  @override
  Future<List<ChatMessageEvent>> fetchChatHistory(String gameId) =>
      throw UnimplementedError();

  @override
  Future<String> sendChat({
    required String gameId,
    required String ciphertext,
  }) => throw UnimplementedError();

  @override
  Future<String> getGameMode(String gameId) => throw UnimplementedError();

  @override
  Future<(String, bool)> myPlayerInfo(String gameId) =>
      throw UnimplementedError();

  @override
  Future<String> replayGame({
    required String gameId,
    required String keyCiphertext,
  }) => throw UnimplementedError();

  @override
  Future<void> uploadReplaySelfie({
    required String path,
    required Uint8List encryptedBytes,
  }) => throw UnimplementedError();

  @override
  Future<void> rejoinReplay({
    required String gameId,
    required String nameCiphertext,
    required String nameHmac,
  }) => throw UnimplementedError();

  @override
  Future<void> leaveFinishedGame(String gameId) => throw UnimplementedError();

  @override
  Future<void> leaveActiveGame(String gameId) => throw UnimplementedError();

  @override
  Future<Map<String, String>> getDeadPlayers(String gameId) =>
      throw UnimplementedError();

  @override
  Future<void> updatePushToken({
    required String gameId,
    required String token,
  }) => throw UnimplementedError();
}

void main() {
  group('SessionResumeService', () {
    late _FakeSecureKeyValueStore keyValueStore;
    late SessionStore store;
    late GameSession session;
    late _FakeGameRepository repository;
    late SessionResumeService service;

    setUp(() {
      keyValueStore = _FakeSecureKeyValueStore();
      store = SessionStore(keyValueStore);
      session = GameSession(store);
      repository = _FakeGameRepository();
      service = SessionResumeService(
        store: store,
        session: session,
        repository: repository,
      );
    });

    test('nothing persisted -> ResumeNone, session stays inactive', () async {
      final outcome = await service.resume();

      expect(outcome, isA<ResumeNone>());
      expect(session.isActive, isFalse);
    });

    test('game still in lobby -> ResumeToLobby, session repopulated', () async {
      final crypto = await GameCrypto.generate();
      await store.save(
        gameId: 'game-1',
        playerId: 'player-1',
        keyBytes: await crypto.keyBytes,
      );
      repository.myState = (
        gameStatus: 'lobby',
        event: null,
        nextPulseAt: null,
        activeWarning: null,
      );

      final outcome = await service.resume();

      expect(outcome, isA<ResumeToLobby>());
      expect(session.isActive, isTrue);
      expect(session.gameId, 'game-1');
      expect(session.playerId, 'player-1');
    });

    test('game active -> ResumeToIngame with a placeholder endsAt', () async {
      final crypto = await GameCrypto.generate();
      await store.save(
        gameId: 'game-1',
        playerId: 'player-1',
        keyBytes: await crypto.keyBytes,
      );
      repository.myState = (
        gameStatus: 'active',
        event: GameEvent.targetAssigned(
          targetId: 'target-1',
          nameCiphertext: 'irrelevant-here',
          selfiePath: 'irrelevant-here',
        ),
        nextPulseAt: null,
        activeWarning: null,
      );

      final outcome = await service.resume();

      expect(outcome, isA<ResumeToIngame>());
      expect(session.isActive, isTrue);
    });

    test(
      'game still dispersing -> ResumeToIngame carries the real endsAt',
      () async {
        final crypto = await GameCrypto.generate();
        await store.save(
          gameId: 'game-1',
          playerId: 'player-1',
          keyBytes: await crypto.keyBytes,
        );
        final endsAt = DateTime.utc(2026, 1, 1, 12);
        repository.myState = (
          gameStatus: 'dispersing',
          event: GameEvent.dispersalStarted(endsAt: endsAt),
          nextPulseAt: null,
          activeWarning: null,
        );

        final outcome = await service.resume();

        expect(outcome, isA<ResumeToIngame>());
        expect((outcome as ResumeToIngame).initialEndsAt, endsAt);
      },
    );

    test(
      'game already finished -> ResumeToFinish, session stays active (#89)',
      () async {
        final crypto = await GameCrypto.generate();
        await store.save(
          gameId: 'game-1',
          playerId: 'player-1',
          keyBytes: await crypto.keyBytes,
        );
        final finishedEvent = GameEvent.gameFinished(
          winnerId: 'player-1',
          stats: const {'players': <dynamic>[]},
          killChain: const [],
        );
        repository.myState = (
          gameStatus: 'finished',
          event: finishedEvent,
          nextPulseAt: null,
          activeWarning: null,
        );

        final outcome = await service.resume();

        expect(outcome, isA<ResumeToFinish>());
        expect((outcome as ResumeToFinish).event, finishedEvent);
        expect(session.isActive, isTrue);
      },
    );

    test(
      'the game is gone (not_found/not_member) -> ResumeNone, session cleared',
      () async {
        final crypto = await GameCrypto.generate();
        await store.save(
          gameId: 'game-1',
          playerId: 'player-1',
          keyBytes: await crypto.keyBytes,
        );
        repository.myStateFailure = Exception('not_found');

        final outcome = await service.resume();

        expect(outcome, isA<ResumeNone>());
        expect(session.isActive, isFalse);
        expect(await store.read(), isNull);
      },
    );
  });
}
