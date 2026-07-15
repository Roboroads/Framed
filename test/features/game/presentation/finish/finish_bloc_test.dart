import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/core/session/session_store.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:framed/features/game/domain/geofence_info.dart';
import 'package:framed/features/game/presentation/finish/finish_bloc.dart';
import 'package:framed/features/game/presentation/finish/finish_state.dart';

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
  Map<String, String> roster = {};
  String mode = 'most_frames';
  final myPlayerInfoByGame = <String, (String, bool)>{};

  String? replayGameNewId;
  Object? replayGameFailure;
  String? capturedReplayKeyCiphertext;

  Uint8List? selfieBytes;
  final uploadedReplaySelfies = <String, Uint8List>{};

  String? rejoinGameId;
  String? rejoinNameCiphertext;
  String? rejoinNameHmac;
  Object? rejoinFailure;

  bool leaveFinishedCalled = false;
  String? leaveFinishedGameId;
  Object? leaveFinishedFailure;

  List<ChatMessageEvent> chatHistory = [];
  Object? chatHistoryFailure;
  Object? sendChatFailure;
  String nextSendChatId = 'msg-1';
  final sentChatCiphertexts = <String>[];

  @override
  Future<Map<String, String>> getRoster(String gameId) async => roster;

  @override
  Future<String> getGameMode(String gameId) async => mode;

  @override
  Future<(String, bool)> myPlayerInfo(String gameId) async =>
      myPlayerInfoByGame[gameId]!;

  @override
  Future<String> replayGame({
    required String gameId,
    required String keyCiphertext,
  }) async {
    if (replayGameFailure != null) throw replayGameFailure!;
    capturedReplayKeyCiphertext = keyCiphertext;
    return replayGameNewId!;
  }

  @override
  Future<Uint8List> downloadSelfie(String path) async => selfieBytes!;

  @override
  Future<void> uploadReplaySelfie({
    required String path,
    required Uint8List encryptedBytes,
  }) async {
    uploadedReplaySelfies[path] = encryptedBytes;
  }

  @override
  Future<void> rejoinReplay({
    required String gameId,
    required String nameCiphertext,
    required String nameHmac,
  }) async {
    if (rejoinFailure != null) throw rejoinFailure!;
    rejoinGameId = gameId;
    rejoinNameCiphertext = nameCiphertext;
    rejoinNameHmac = nameHmac;
  }

  @override
  Future<void> leaveFinishedGame(String gameId) async {
    leaveFinishedCalled = true;
    leaveFinishedGameId = gameId;
    if (leaveFinishedFailure != null) throw leaveFinishedFailure!;
  }

  @override
  Future<void> leaveActiveGame(String gameId) => throw UnimplementedError();

  @override
  Future<void> updatePushToken({
    required String gameId,
    required String token,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List> downloadFramePhoto(String path) =>
      throw UnimplementedError();

  @override
  Future<void> castVote({required String frameId, required bool vote}) =>
      throw UnimplementedError();

  @override
  Future<void> submitFrame({
    required String gameId,
    required String photoPath,
  }) => throw UnimplementedError();

  @override
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  }) => throw UnimplementedError();

  @override
  Future<GeofenceInfo> getGeofence(String gameId) => throw UnimplementedError();

  @override
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  }) => throw UnimplementedError();

  @override
  Future<MyStateResult> getMyState(String gameId) => throw UnimplementedError();

  @override
  Future<List<ChatMessageEvent>> fetchChatHistory(String gameId) async {
    if (chatHistoryFailure != null) throw chatHistoryFailure!;
    return chatHistory;
  }

  @override
  Future<String> sendChat({
    required String gameId,
    required String ciphertext,
  }) async {
    if (sendChatFailure != null) throw sendChatFailure!;
    sentChatCiphertexts.add(ciphertext);
    return nextSendChatId;
  }
}

void main() {
  group('FinishBloc', () {
    late GameCrypto oldCrypto;
    late _FakeGameRepository repository;
    late GameSession session;
    late StreamController<GameEvent> gameEvents;
    late StreamController<GameEvent> deadChatEvents;

    setUp(() async {
      oldCrypto = await GameCrypto.generate();
      repository = _FakeGameRepository();
      session = GameSession(SessionStore(_FakeSecureKeyValueStore()));
      gameEvents = StreamController<GameEvent>();
      deadChatEvents = StreamController<GameEvent>();
    });

    tearDown(() {
      gameEvents.close();
      deadChatEvents.close();
    });

    GameFinished event({required String winnerId}) => GameFinished(
      winnerId: winnerId,
      stats: {
        'players': [
          {
            'player_id': 'p1',
            'kills': 2,
            'distance_moved_m': 100.0,
            'still_seconds': 10,
            'survived_seconds': 500,
          },
          {
            'player_id': 'p2',
            'kills': 0,
            'distance_moved_m': 50.0,
            'still_seconds': 5,
            'survived_seconds': 300,
          },
        ],
        'total_distance_moved_m': 150.0,
        'duration_seconds': 500,
      },
      killChain: [
        {
          'victim_id': 'p2',
          'killer_id': 'p1',
          'cause': 'framed',
          'died_at': '2026-01-01T00:00:00.000Z',
        },
      ],
    );

    test(
      'decrypts the roster and builds stats/kill chain; winner is youWon',
      () async {
        repository.roster = {
          'p1': await oldCrypto.encryptString('Alice'),
          'p2': await oldCrypto.encryptString('Bob'),
        };
        repository.mode = 'most_frames';
        repository.myPlayerInfoByGame['game-1'] = ('p1', true);

        final bloc = FinishBloc(
          initialEvent: event(winnerId: 'p1'),
          gameEvents: gameEvents.stream,
          deadChatEvents: deadChatEvents.stream,
          crypto: oldCrypto,
          repository: repository,
          session: session,
          gameId: 'game-1',
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.loading, isFalse);
        expect(bloc.state.winnerId, 'p1');
        expect(bloc.state.winnerName, 'Alice');
        expect(bloc.state.youWon, isTrue);
        expect(bloc.state.isHost, isTrue);
        expect(bloc.state.mode, 'most_frames');
        expect(bloc.state.stats, hasLength(2));
        expect(bloc.state.stats.first.name, 'Alice');
        expect(bloc.state.totalDistanceMovedM, 150.0);
        expect(bloc.state.durationSeconds, 500);
        expect(bloc.state.killChain, hasLength(1));
        expect(bloc.state.killChain.first.victimName, 'Bob');
        expect(bloc.state.killChain.first.killerName, 'Alice');
        expect(bloc.state.killChain.first.cause, 'framed');
      },
    );

    test(
      'youWon and isHost are false for a non-winning, non-host caller',
      () async {
        repository.roster = {
          'p1': await oldCrypto.encryptString('Alice'),
          'p2': await oldCrypto.encryptString('Bob'),
        };
        repository.myPlayerInfoByGame['game-1'] = ('p2', false);

        final bloc = FinishBloc(
          initialEvent: event(winnerId: 'p1'),
          gameEvents: gameEvents.stream,
          deadChatEvents: deadChatEvents.stream,
          crypto: oldCrypto,
          repository: repository,
          session: session,
          gameId: 'game-1',
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.youWon, isFalse);
        expect(bloc.state.isHost, isFalse);
      },
    );

    test('a mia kill chain entry has no killer name', () async {
      repository.roster = {'p1': await oldCrypto.encryptString('Alice')};
      repository.myPlayerInfoByGame['game-1'] = ('p1', true);

      final miaEvent = GameFinished(
        winnerId: 'p1',
        stats: const {
          'players': [
            {
              'player_id': 'p1',
              'kills': 0,
              'distance_moved_m': 0.0,
              'still_seconds': 0,
              'survived_seconds': 100,
            },
          ],
          'total_distance_moved_m': 0.0,
          'duration_seconds': 100,
        },
        killChain: [
          {
            'victim_id': 'p2',
            'killer_id': null,
            'cause': 'mia',
            'died_at': '2026-01-01T00:00:00.000Z',
          },
        ],
      );

      final bloc = FinishBloc(
        initialEvent: miaEvent,
        gameEvents: gameEvents.stream,
        deadChatEvents: deadChatEvents.stream,
        crypto: oldCrypto,
        repository: repository,
        session: session,
        gameId: 'game-1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.killChain.first.killerName, isNull);
      expect(bloc.state.killChain.first.cause, 'mia');
    });

    test(
      'startReplay is a no-op for a non-host; a host encrypts a fresh key under the old one',
      () async {
        repository.roster = {'p1': await oldCrypto.encryptString('Alice')};
        repository.myPlayerInfoByGame['game-1'] = ('p2', false);

        final nonHostBloc = FinishBloc(
          initialEvent: event(winnerId: 'p1'),
          gameEvents: gameEvents.stream,
          deadChatEvents: deadChatEvents.stream,
          crypto: oldCrypto,
          repository: repository,
          session: session,
          gameId: 'game-1',
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await nonHostBloc.startReplay();
        expect(repository.capturedReplayKeyCiphertext, isNull);

        repository.myPlayerInfoByGame['game-1'] = ('p1', true);
        repository.replayGameNewId = 'new-game-1';
        final hostGameEvents = StreamController<GameEvent>();
        addTearDown(hostGameEvents.close);
        final hostDeadChatEvents = StreamController<GameEvent>();
        addTearDown(hostDeadChatEvents.close);
        final hostBloc = FinishBloc(
          initialEvent: event(winnerId: 'p1'),
          gameEvents: hostGameEvents.stream,
          deadChatEvents: hostDeadChatEvents.stream,
          crypto: oldCrypto,
          repository: repository,
          session: session,
          gameId: 'game-1',
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await hostBloc.startReplay();

        final ciphertext = repository.capturedReplayKeyCiphertext;
        expect(ciphertext, isNotNull);
        final decryptedKeyBytes = await oldCrypto.decrypt(ciphertext!);
        expect(decryptedKeyBytes, hasLength(32)); // AES-256 key
        // Round-trips into a usable key — doesn't throw.
        await GameCrypto.fromKeyBytes(decryptedKeyBytes);
      },
    );

    test('replay_started runs the full handshake: identity refreshed, '
        'selfie re-uploaded, session swapped', () async {
      final newCrypto = await GameCrypto.generate();
      final keyCiphertext = await oldCrypto.encrypt(await newCrypto.keyBytes);

      repository.roster = {'p1': await oldCrypto.encryptString('Alice')};
      repository.myPlayerInfoByGame['game-1'] = ('p1', true);
      repository.myPlayerInfoByGame['new-game-1'] = ('new-p1', true);
      repository.selfieBytes = await oldCrypto.encryptBytes(
        utf8.encode('fake-selfie'),
      );

      final bloc = FinishBloc(
        initialEvent: event(winnerId: 'p1'),
        gameEvents: gameEvents.stream,
        deadChatEvents: deadChatEvents.stream,
        crypto: oldCrypto,
        repository: repository,
        session: session,
        gameId: 'game-1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      gameEvents.add(
        GameEvent.replayStarted(
          newGameId: 'new-game-1',
          keyCiphertext: keyCiphertext,
          joinToken: 'tok',
        ),
      );
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(bloc.state.replayStatus, FinishReplayStatus.idle);
      expect(bloc.state.replayReadyGameId, 'new-game-1');

      expect(repository.rejoinGameId, 'new-game-1');
      final rejoinedName = await newCrypto.decryptString(
        repository.rejoinNameCiphertext!,
      );
      expect(rejoinedName, 'Alice');
      expect(repository.rejoinNameHmac, await newCrypto.nameHmac('Alice'));

      final uploaded = repository.uploadedReplaySelfies['new-game-1/new-p1'];
      expect(uploaded, isNotNull);
      expect(
        await newCrypto.decryptBytes(uploaded!),
        utf8.encode('fake-selfie'),
      );

      expect(session.gameId, 'new-game-1');
      expect(session.playerId, 'new-p1');
      expect(await session.crypto.keyBytes, await newCrypto.keyBytes);
    });

    test('a failure mid-handshake surfaces replayStatus.error', () async {
      final newCrypto = await GameCrypto.generate();
      final keyCiphertext = await oldCrypto.encrypt(await newCrypto.keyBytes);

      repository.roster = {'p1': await oldCrypto.encryptString('Alice')};
      repository.myPlayerInfoByGame['game-1'] = ('p1', true);
      repository.myPlayerInfoByGame['new-game-1'] = ('new-p1', true);
      repository.selfieBytes = await oldCrypto.encryptBytes(
        utf8.encode('fake-selfie'),
      );
      repository.rejoinFailure = Exception('offline');

      final bloc = FinishBloc(
        initialEvent: event(winnerId: 'p1'),
        gameEvents: gameEvents.stream,
        deadChatEvents: deadChatEvents.stream,
        crypto: oldCrypto,
        repository: repository,
        session: session,
        gameId: 'game-1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      gameEvents.add(
        GameEvent.replayStarted(
          newGameId: 'new-game-1',
          keyCiphertext: keyCiphertext,
          joinToken: 'tok',
        ),
      );
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(bloc.state.replayStatus, FinishReplayStatus.error);
      expect(bloc.state.replayReadyGameId, isNull);
    });

    test('leave() clears the session even when the RPC call fails', () async {
      repository.roster = {'p1': await oldCrypto.encryptString('Alice')};
      repository.myPlayerInfoByGame['game-1'] = ('p1', false);
      repository.leaveFinishedFailure = Exception('offline');
      await session.begin(gameId: 'game-1', playerId: 'p1', crypto: oldCrypto);

      final bloc = FinishBloc(
        initialEvent: event(winnerId: 'p2'),
        gameEvents: gameEvents.stream,
        deadChatEvents: deadChatEvents.stream,
        crypto: oldCrypto,
        repository: repository,
        session: session,
        gameId: 'game-1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.leave();

      expect(repository.leaveFinishedCalled, isTrue);
      expect(repository.leaveFinishedGameId, 'game-1');
      expect(session.isActive, isFalse);
    });

    test('chat: history loads decrypted, live merges in order, '
        'the optimistic echo of a sent message dedupes', () async {
      repository.roster = {
        'p1': await oldCrypto.encryptString('Alice'),
        'p2': await oldCrypto.encryptString('Bob'),
      };
      repository.myPlayerInfoByGame['game-1'] = ('p1', false);
      repository.chatHistory = [
        ChatMessageEvent(
          messageId: 'hist-1',
          senderId: 'p2',
          ciphertext: await oldCrypto.encryptString('hello from history'),
          createdAt: DateTime.utc(2026, 1, 1, 11),
        ),
      ];

      final bloc = FinishBloc(
        initialEvent: event(winnerId: 'p1'),
        gameEvents: gameEvents.stream,
        deadChatEvents: deadChatEvents.stream,
        crypto: oldCrypto,
        repository: repository,
        session: session,
        gameId: 'game-1',
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.chat, hasLength(1));
      expect(bloc.state.chat.first.text, 'hello from history');
      expect(bloc.state.chat.first.senderName, 'Bob');

      repository.nextSendChatId = 'msg-optimistic';
      await bloc.sendChatMessage('hi there');

      expect(bloc.state.chat, hasLength(2));
      expect(bloc.state.chat.last.text, 'hi there');
      expect(bloc.state.chat.last.senderName, 'Alice');

      // The optimistic echo of the same message arriving over the live
      // channel dedupes against its own id instead of double-appending.
      deadChatEvents.add(
        ChatMessageEvent(
          messageId: 'msg-optimistic',
          senderId: 'p1',
          ciphertext: await oldCrypto.encryptString('hi there'),
          createdAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.chat, hasLength(2));

      // A genuinely new message from someone else still appends.
      deadChatEvents.add(
        ChatMessageEvent(
          messageId: 'live-1',
          senderId: 'p2',
          ciphertext: await oldCrypto.encryptString('meet at the fountain'),
          createdAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.chat, hasLength(3));
      expect(bloc.state.chat.last.text, 'meet at the fountain');
    });
  });
}
