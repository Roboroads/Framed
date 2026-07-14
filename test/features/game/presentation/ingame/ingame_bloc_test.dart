import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/location/wake_lock_service.dart';
import 'package:framed/core/push/local_alarms.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/core/session/session_store.dart';
import 'package:framed/features/game/domain/frame_error.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:framed/features/game/domain/geofence_info.dart';
import 'package:framed/features/game/presentation/ingame/ingame_bloc.dart';
import 'package:framed/features/game/presentation/ingame/ingame_state.dart';
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

class _FakeWakeLockService implements WakeLockService {
  int enableCallCount = 0;
  int disableCallCount = 0;
  bool? lastEnabled;

  @override
  Future<void> enable() async {
    enableCallCount++;
    lastEnabled = true;
  }

  @override
  Future<void> disable() async {
    disableCallCount++;
    lastEnabled = false;
  }
}

class _FakeLocalAlarms implements LocalAlarms {
  DateTime? scheduledCompassPulse;
  DateTime? scheduledWarningDeadline;
  int cancelCompassPulseCallCount = 0;
  int cancelWarningDeadlineCallCount = 0;
  int cancelAllCallCount = 0;

  @override
  Future<void> scheduleCompassPulse(DateTime at) async {
    scheduledCompassPulse = at;
  }

  @override
  Future<void> cancelCompassPulse() async {
    cancelCompassPulseCallCount++;
    scheduledCompassPulse = null;
  }

  @override
  Future<void> scheduleWarningDeadline(DateTime at) async {
    scheduledWarningDeadline = at;
  }

  @override
  Future<void> cancelWarningDeadline() async {
    cancelWarningDeadlineCallCount++;
    scheduledWarningDeadline = null;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
    scheduledCompassPulse = null;
    scheduledWarningDeadline = null;
  }
}

class _FakeGameRepository implements GameRepository {
  Uint8List? selfieBytes;
  Object? failure;

  /// When true, each call parks on its own completer (in call order)
  /// instead of resolving immediately — lets a test control which of two
  /// concurrent downloads "finishes" first.
  bool controlled = false;
  final completers = <Completer<Uint8List>>[];

  Object? frameFailure;
  String? lastUploadedPhotoPath;
  String? lastSubmittedPhotoPath;

  Uint8List? framePhotoBytes;
  Object? framePhotoFailure;
  String? lastVotedFrameId;
  bool? lastVote;
  int downloadFramePhotoCalls = 0;

  @override
  Future<Uint8List> downloadSelfie(String path) {
    if (failure != null) throw failure!;
    if (controlled) {
      final completer = Completer<Uint8List>();
      completers.add(completer);
      return completer.future;
    }
    return Future.value(selfieBytes);
  }

  @override
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  }) async {}

  @override
  Future<GeofenceInfo> getGeofence(String gameId) async {
    return const GeofenceInfo(lat: 0, lng: 0, radiusM: 200);
  }

  @override
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  }) async {
    if (frameFailure != null) throw frameFailure!;
    lastUploadedPhotoPath = photoPath;
  }

  @override
  Future<void> submitFrame({
    required String gameId,
    required String photoPath,
  }) async {
    if (frameFailure != null) throw frameFailure!;
    lastSubmittedPhotoPath = photoPath;
  }

  @override
  Future<Uint8List> downloadFramePhoto(String path) async {
    downloadFramePhotoCalls++;
    if (framePhotoFailure != null) throw framePhotoFailure!;
    return framePhotoBytes!;
  }

  @override
  Future<void> castVote({required String frameId, required bool vote}) async {
    lastVotedFrameId = frameId;
    lastVote = vote;
  }

  GameEvent? myState;
  String myGameStatus = 'active';
  DateTime? myNextPulseAt;
  GameEvent? myActiveWarning;
  Object? myStateFailure;
  Completer<MyStateResult>? myStateCompleter;
  int myStateCallCount = 0;

  @override
  Future<MyStateResult> getMyState(String gameId) {
    myStateCallCount++;
    if (myStateCompleter != null) return myStateCompleter!.future;
    if (myStateFailure != null) throw myStateFailure!;
    return Future.value((
      gameStatus: myGameStatus,
      event: myState,
      nextPulseAt: myNextPulseAt,
      activeWarning: myActiveWarning,
    ));
  }

  Map<String, String> roster = {};
  Object? rosterFailure;
  List<ChatMessageEvent> chatHistory = [];
  Object? chatHistoryFailure;
  Object? sendChatFailure;
  String nextSendChatId = 'msg-1';
  final sentChatCiphertexts = <String>[];

  @override
  Future<Map<String, String>> getRoster(String gameId) async {
    if (rosterFailure != null) throw rosterFailure!;
    return roster;
  }

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

  bool leaveActiveCalled = false;
  Object? leaveActiveFailure;

  @override
  Future<void> leaveActiveGame(String gameId) async {
    leaveActiveCalled = true;
    if (leaveActiveFailure != null) throw leaveActiveFailure!;
  }

  @override
  Future<void> updatePushToken({
    required String gameId,
    required String token,
  }) => throw UnimplementedError();
}

void main() {
  group('IngameBloc', () {
    late GameCrypto crypto;
    late _FakeGameRepository repository;
    late _FakeLocalAlarms localAlarms;
    late GameSession session;
    late _FakeWakeLockService wakeLockService;
    late StreamController<GameEvent> events;
    late DateTime endsAt;

    setUp(() async {
      crypto = await GameCrypto.generate();
      repository = _FakeGameRepository();
      localAlarms = _FakeLocalAlarms();
      session = GameSession(SessionStore(_FakeSecureKeyValueStore()));
      wakeLockService = _FakeWakeLockService();
      events = StreamController<GameEvent>();
      endsAt = DateTime.utc(2026, 1, 1, 12);
    });

    tearDown(() => events.close());

    test('starts dispersing at the given endsAt', () {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      expect(
        bloc.state,
        IngameState(phase: IngamePhase.dispersing(endsAt: endsAt)),
      );
    });

    test('resolves myName from the roster on init', () async {
      repository.roster = {'player-me': await crypto.encryptString('Bob')};

      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.myName, 'Bob');
    });

    test('a roster without this player leaves myName unset', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.myName, isNull);
    });

    test('dispersing -> playing on target_assigned', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      final selfieBytes = Uint8List.fromList([1, 2, 3, 4]);
      repository.selfieBytes = await crypto.encryptBytes(selfieBytes);

      events.add(
        GameEvent.targetAssigned(
          targetId: 'target-1',
          nameCiphertext: await crypto.encryptString('Alice'),
          selfiePath: 'game-1/target-1',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final phase = bloc.state.phase;
      expect(phase, isA<IngamePlaying>());
      final target = (phase as IngamePlaying).target;
      expect(target.playerId, 'target-1');
      expect(target.name, 'Alice');
      expect(target.selfieBytes, selfieBytes);
    });

    test(
      'a selfie that fails to load surfaces targetLoadFailed, not a crash',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        repository.failure = Exception('storage unavailable');

        events.add(
          GameEvent.targetAssigned(
            targetId: 'target-1',
            nameCiphertext: await crypto.encryptString('Alice'),
            selfiePath: 'game-1/target-1',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state,
          const IngameState(phase: IngamePhase.targetLoadFailed()),
        );
      },
    );

    test(
      'a newer target_assigned wins even if its download finishes first',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        repository.controlled = true;

        events.add(
          GameEvent.targetAssigned(
            targetId: 'first',
            nameCiphertext: await crypto.encryptString('First'),
            selfiePath: 'game-1/first',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        events.add(
          GameEvent.targetAssigned(
            targetId: 'second',
            nameCiphertext: await crypto.encryptString('Second'),
            selfiePath: 'game-1/second',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repository.completers, hasLength(2));
        // The newer (second) download resolves first; the stale (first)
        // one lands after — it must not overwrite the newer state.
        repository.completers[1].complete(
          await crypto.encryptBytes(Uint8List.fromList([2, 2])),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        repository.completers[0].complete(
          await crypto.encryptBytes(Uint8List.fromList([1, 1])),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final phase = bloc.state.phase;
        expect(phase, isA<IngamePlaying>());
        expect((phase as IngamePlaying).target.playerId, 'second');
      },
    );

    test(
      'the startup catch-up fetch applies a target no live event ever sends',
      () async {
        repository.myState = GameEvent.targetAssigned(
          targetId: 'target-1',
          nameCiphertext: await crypto.encryptString('Alice'),
          selfiePath: 'game-1/target-1',
        );
        repository.selfieBytes = await crypto.encryptBytes(
          Uint8List.fromList([9]),
        );

        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final phase = bloc.state.phase;
        expect(phase, isA<IngamePlaying>());
        expect((phase as IngamePlaying).target.playerId, 'target-1');
      },
    );

    test('a live target_assigned beats a slower catch-up fetch', () async {
      repository.myStateCompleter = Completer<MyStateResult>();
      repository.selfieBytes = await crypto.encryptBytes(
        Uint8List.fromList([1]),
      );

      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      events.add(
        GameEvent.targetAssigned(
          targetId: 'live',
          nameCiphertext: await crypto.encryptString('Live'),
          selfiePath: 'game-1/live',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // The catch-up resolves after the live event already landed — its
      // (now stale) target must not overwrite the live one's.
      repository.myStateCompleter!.complete((
        gameStatus: 'active',
        event: GameEvent.targetAssigned(
          targetId: 'stale',
          nameCiphertext: await crypto.encryptString('Stale'),
          selfiePath: 'game-1/stale',
        ),
        nextPulseAt: null,
        activeWarning: null,
      ));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final phase = bloc.state.phase;
      expect(phase, isA<IngamePlaying>());
      expect((phase as IngamePlaying).target.playerId, 'live');
    });

    test('you_died sets the dead phase', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.youDied(
          cause: 'framed',
          killerNameCiphertext: await crypto.encryptString('Killer'),
          survivedSeconds: 120,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.phase,
        const IngamePhase.dead(
          cause: 'framed',
          killerName: 'Killer',
          survivedSeconds: 120,
        ),
      );
      expect(localAlarms.cancelAllCallCount, 1);
    });

    test('you_died with a photo downloads and decrypts it', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      final original = Uint8List.fromList(List.generate(20, (i) => i));
      repository.framePhotoBytes = await crypto.encryptBytes(original);

      events.add(
        GameEvent.youDied(
          cause: 'framed',
          killerNameCiphertext: await crypto.encryptString('Killer'),
          photoPath: 'game-1/frame-1',
          survivedSeconds: 120,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final phase = bloc.state.phase as IngameDead;
      expect(phase.photoBytes, original);
      expect(repository.downloadFramePhotoCalls, 1);
    });

    test('you_died for a mia death has no photo to download', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(const GameEvent.youDied(cause: 'mia', survivedSeconds: 300));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final phase = bloc.state.phase as IngameDead;
      expect(phase.photoBytes, isNull);
      expect(repository.downloadFramePhotoCalls, 0);
    });

    test(
      'the catch-up fetch can report dead directly (cold-start resume)',
      () async {
        repository.myState = const GameEvent.youDied(
          cause: 'mia',
          survivedSeconds: 300,
        );

        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state.phase,
          const IngamePhase.dead(
            cause: 'mia',
            killerName: null,
            survivedSeconds: 300,
          ),
        );
      },
    );

    test(
      'the catch-up fetch updates the dispersal endsAt on a cold-start resume',
      () async {
        final serverEndsAt = endsAt.add(const Duration(minutes: 3));
        repository.myState = GameEvent.dispersalStarted(endsAt: serverEndsAt);

        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.phase, IngamePhase.dispersing(endsAt: serverEndsAt));
      },
    );

    test(
      'the catch-up fetch carries nextPulseAt regardless of the event',
      () async {
        final nextPulseAt = endsAt.add(const Duration(minutes: 5));
        repository.myState = GameEvent.dispersalStarted(endsAt: endsAt);
        repository.myNextPulseAt = nextPulseAt;

        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.nextPulseAt, nextPulseAt);
        expect(localAlarms.scheduledCompassPulse, nextPulseAt);
      },
    );

    test('a failed catch-up fetch is silently ignored', () async {
      repository.myStateFailure = Exception('network error');

      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state,
        IngameState(phase: IngamePhase.dispersing(endsAt: endsAt)),
      );
    });

    test('unrelated events are ignored', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(const GameEvent.playerLeft(playerId: 'someone-else'));
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state,
        IngameState(phase: IngamePhase.dispersing(endsAt: endsAt)),
      );
    });

    test('warning active:true sets the overlay', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      final deadline = DateTime.utc(2026, 1, 1, 12, 5);

      events.add(
        GameEvent.warning(
          active: true,
          reasons: const ['geofence'],
          hardDeadline: deadline,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.warning,
        IngameWarning(reasons: const ['geofence'], hardDeadline: deadline),
      );
      // The phase underneath is untouched by a warning.
      expect(bloc.state.phase, IngamePhase.dispersing(endsAt: endsAt));
      expect(localAlarms.scheduledWarningDeadline, deadline);
    });

    test('warning active:false clears the overlay', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.warning(
          active: true,
          reasons: const ['stale'],
          hardDeadline: DateTime.utc(2026, 1, 1, 12, 5),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.warning, isNotNull);

      events.add(const GameEvent.warning(active: false));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.warning, isNull);
      expect(localAlarms.cancelWarningDeadlineCallCount, 1);
    });

    test(
      'a warning past its deadline with no resolution re-fetches state',
      () async {
        IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
          warningResyncGrace: const Duration(milliseconds: 20),
        );
        repository.myGameStatus = 'active';

        events.add(
          GameEvent.warning(
            active: true,
            reasons: const ['geofence'],
            // Already past — the resync timer only waits the grace period
            // from now, not from the (already-elapsed) deadline.
            hardDeadline: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(repository.myStateCallCount, 1); // the constructor's own

        await Future<void>.delayed(const Duration(milliseconds: 40));

        expect(repository.myStateCallCount, 2);
      },
    );

    test(
      'the catch-up fetch applies an active_warning independent of the phase event',
      () async {
        repository.myState = GameEvent.dispersalStarted(endsAt: endsAt);
        final deadline = DateTime.now().add(const Duration(minutes: 3));
        repository.myActiveWarning = GameEvent.warning(
          active: true,
          reasons: const ['stale'],
          hardDeadline: deadline,
        );

        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.phase, IngamePhase.dispersing(endsAt: endsAt));
        expect(
          bloc.state.warning,
          IngameWarning(reasons: const ['stale'], hardDeadline: deadline),
        );
      },
    );

    test('geofence_proximity active:true sets nearGeofenceEdge', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(const GameEvent.geofenceProximity(active: true));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.nearGeofenceEdge, isTrue);
      // Distinct from warning — unrelated to it either way.
      expect(bloc.state.warning, isNull);
    });

    test('geofence_proximity active:false clears nearGeofenceEdge', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(const GameEvent.geofenceProximity(active: true));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.nearGeofenceEdge, isTrue);

      events.add(const GameEvent.geofenceProximity(active: false));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.nearGeofenceEdge, isFalse);
    });

    test('compass_pulse sets the snapshot until it expires', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.compassPulse(
          bearingDeg: 42,
          distanceM: 1234,
          expiresAt: DateTime.now().add(const Duration(milliseconds: 50)),
          nextPulseAt: DateTime.now().add(const Duration(minutes: 10)),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final compass = bloc.state.compass;
      expect(compass, isNotNull);
      expect(compass!.bearingDeg, 42);
      expect(compass.distanceM, 1234);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(bloc.state.compass, isNull);
    });

    test(
      'compass_pulse sets nextPulseAt for the following countdown',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        final nextPulseAt = DateTime.now().add(const Duration(minutes: 10));

        events.add(
          GameEvent.compassPulse(
            bearingDeg: 42,
            distanceM: 1234,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 50)),
            nextPulseAt: nextPulseAt,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.nextPulseAt, nextPulseAt);
        expect(localAlarms.scheduledCompassPulse, nextPulseAt);

        // nextPulseAt survives the pulse itself expiring — the countdown to
        // the following one is exactly what should still be on screen.
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(bloc.state.compass, isNull);
        expect(bloc.state.nextPulseAt, nextPulseAt);
      },
    );

    test('an already-expired compass_pulse on arrival is dropped', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.compassPulse(
          bearingDeg: 42,
          distanceM: 1234,
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
          nextPulseAt: DateTime.now().add(const Duration(minutes: 10)),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.compass, isNull);
    });

    test(
      'a newer compass_pulse is not cleared by an older one\'s timer',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );

        events.add(
          GameEvent.compassPulse(
            bearingDeg: 1,
            distanceM: 100,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 30)),
            nextPulseAt: DateTime.now().add(const Duration(minutes: 10)),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        events.add(
          GameEvent.compassPulse(
            bearingDeg: 2,
            distanceM: 200,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 200)),
            nextPulseAt: DateTime.now().add(const Duration(minutes: 10)),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 60));

        // The first pulse's timer would have fired by now; the second pulse
        // must still be showing.
        expect(bloc.state.compass?.bearingDeg, 2);
      },
    );

    test(
      'target_location sets the panel and updates as ticks arrive',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
          targetLocationTimeout: const Duration(milliseconds: 50),
        );

        events.add(const GameEvent.targetLocation(lat: 1, lng: 2));
        await Future<void>.delayed(Duration.zero);
        expect(
          bloc.state.targetLocation,
          const IngameTargetLocation(lat: 1, lng: 2),
        );

        events.add(const GameEvent.targetLocation(lat: 3, lng: 4));
        await Future<void>.delayed(Duration.zero);
        expect(
          bloc.state.targetLocation,
          const IngameTargetLocation(lat: 3, lng: 4),
        );
      },
    );

    test(
      'the panel clears after the silence timeout with no new tick',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
          targetLocationTimeout: const Duration(milliseconds: 30),
        );

        events.add(const GameEvent.targetLocation(lat: 1, lng: 2));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.targetLocation, isNotNull);

        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(bloc.state.targetLocation, isNull);
      },
    );

    test('a fresh tick resets the silence timeout clock', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
        targetLocationTimeout: const Duration(milliseconds: 50),
      );

      events.add(const GameEvent.targetLocation(lat: 1, lng: 2));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      // A tick arrives before the 50ms timeout elapses — the clock restarts.
      events.add(const GameEvent.targetLocation(lat: 5, lng: 6));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // 60ms have passed since the first tick (which would have expired by
      // 50ms), but only 30ms since the second — still showing.
      expect(
        bloc.state.targetLocation,
        const IngameTargetLocation(lat: 5, lng: 6),
      );
    });

    test('starts ready', () {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      expect(bloc.state.frameStatus, const IngameFrameStatus.ready());
    });

    test('submitFrame uploads, submits, and moves to waiting', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      final error = await bloc.submitFrame(
        photoBytes: Uint8List.fromList([1, 2, 3]),
        frameUuid: 'uuid-1',
      );

      expect(error, isNull);
      expect(repository.lastUploadedPhotoPath, 'game-1/uuid-1');
      expect(repository.lastSubmittedPhotoPath, 'game-1/uuid-1');
      expect(
        bloc.state.frameStatus,
        const IngameFrameStatus.waitingForVerdict(),
      );
    });

    test('submitFrame surfaces the server error and stays ready', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      repository.frameFailure = PostgrestException(message: 'on_cooldown');

      final error = await bloc.submitFrame(
        photoBytes: Uint8List.fromList([1, 2, 3]),
        frameUuid: 'uuid-1',
      );

      expect(error, FrameError.onCooldown);
      expect(bloc.state.frameStatus, const IngameFrameStatus.ready());
    });

    test('a second submitFrame while waiting is a no-op', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      await bloc.submitFrame(
        photoBytes: Uint8List.fromList([1, 2, 3]),
        frameUuid: 'uuid-1',
      );

      final error = await bloc.submitFrame(
        photoBytes: Uint8List.fromList([4, 5, 6]),
        frameUuid: 'uuid-2',
      );

      expect(error, isNull);
      // still the first attempt's path — the second call never reached
      // the repository
      expect(repository.lastSubmittedPhotoPath, 'game-1/uuid-1');
    });

    test('frame_verdict passed:true returns to ready', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      await bloc.submitFrame(
        photoBytes: Uint8List.fromList([1, 2, 3]),
        frameUuid: 'uuid-1',
      );

      events.add(const GameEvent.frameVerdict(passed: true));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.frameStatus, const IngameFrameStatus.ready());
    });

    test(
      'frame_verdict passed:false starts a cooldown that clears itself',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        await bloc.submitFrame(
          photoBytes: Uint8List.fromList([1, 2, 3]),
          frameUuid: 'uuid-1',
        );
        final until = DateTime.now().add(const Duration(milliseconds: 50));

        events.add(GameEvent.frameVerdict(passed: false, cooldownUntil: until));
        await Future<void>.delayed(Duration.zero);

        expect(
          bloc.state.frameStatus,
          IngameFrameStatus.cooldown(until: until),
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(bloc.state.frameStatus, const IngameFrameStatus.ready());
      },
    );

    test('frame_to_judge loads and joins the queue', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      final photoBytes = Uint8List.fromList([9, 9, 9]);
      repository.framePhotoBytes = await crypto.encryptBytes(photoBytes);
      repository.selfieBytes = await crypto.encryptBytes(
        Uint8List.fromList([8, 8]),
      );

      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-1',
          photoPath: 'game-1/uuid-x',
          targetNameCiphertext: await crypto.encryptString('Bob'),
          targetSelfiePath: 'game-1/bob',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.judgingQueue, hasLength(1));
      final loaded = bloc.state.judgingQueue.first.loaded;
      expect(loaded, isNotNull);
      expect(loaded!.targetName, 'Bob');
      expect(loaded.photoBytes, photoBytes);
    });

    test('a second frame_to_judge queues behind the first, unloaded', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      repository.controlled = true;
      repository.framePhotoBytes = await crypto.encryptBytes(
        Uint8List.fromList([1]),
      );

      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-1',
          photoPath: 'game-1/uuid-1',
          targetNameCiphertext: await crypto.encryptString('Bob'),
          targetSelfiePath: 'game-1/bob',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-2',
          photoPath: 'game-1/uuid-2',
          targetNameCiphertext: await crypto.encryptString('Carol'),
          targetSelfiePath: 'game-1/carol',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.judgingQueue, hasLength(2));
      expect(bloc.state.judgingQueue.first.loaded, isNull);
      expect(bloc.state.judgingQueue.last.loaded, isNull);
      // only the front's download ever started
      expect(repository.downloadFramePhotoCalls, 1);
    });

    test('castVote removes the front and loads the next one', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      repository.framePhotoBytes = await crypto.encryptBytes(
        Uint8List.fromList([1]),
      );
      repository.selfieBytes = await crypto.encryptBytes(
        Uint8List.fromList([2]),
      );

      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-1',
          photoPath: 'game-1/uuid-1',
          targetNameCiphertext: await crypto.encryptString('Bob'),
          targetSelfiePath: 'game-1/bob',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-2',
          photoPath: 'game-1/uuid-2',
          targetNameCiphertext: await crypto.encryptString('Carol'),
          targetSelfiePath: 'game-1/carol',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.castVote(frameId: 'frame-1', vote: true);

      expect(repository.lastVotedFrameId, 'frame-1');
      expect(repository.lastVote, true);
      expect(bloc.state.judgingQueue, hasLength(1));
      expect(bloc.state.judgingQueue.first.frameId, 'frame-2');
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.judgingQueue.first.loaded?.targetName, 'Carol');
    });

    test('frame_cancelled drops the matching entry from the queue', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );
      repository.framePhotoBytes = await crypto.encryptBytes(
        Uint8List.fromList([1]),
      );
      repository.selfieBytes = await crypto.encryptBytes(
        Uint8List.fromList([2]),
      );

      events.add(
        GameEvent.frameToJudge(
          frameId: 'frame-1',
          photoPath: 'game-1/uuid-1',
          targetNameCiphertext: await crypto.encryptString('Bob'),
          targetSelfiePath: 'game-1/bob',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      events.add(const GameEvent.frameCancelled(frameId: 'frame-1'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.judgingQueue, isEmpty);
    });

    test(
      'a failed image load marks the entry failed; retryFrontLoad recovers',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          localAlarms: localAlarms,
          session: session,
          wakeLockService: wakeLockService,
          gameId: 'game-1',
          myPlayerId: 'player-me',
          deadChatEvents: const Stream<GameEvent>.empty(),
          initialEndsAt: endsAt,
        );
        repository.framePhotoFailure = Exception('offline');

        events.add(
          GameEvent.frameToJudge(
            frameId: 'frame-1',
            photoPath: 'game-1/uuid-1',
            targetNameCiphertext: await crypto.encryptString('Bob'),
            targetSelfiePath: 'game-1/bob',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.judgingQueue.first.failed, isTrue);
        expect(bloc.state.judgingQueue.first.loaded, isNull);

        repository.framePhotoFailure = null;
        repository.framePhotoBytes = await crypto.encryptBytes(
          Uint8List.fromList([3]),
        );
        repository.selfieBytes = await crypto.encryptBytes(
          Uint8List.fromList([4]),
        );
        bloc.retryFrontLoad();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.judgingQueue.first.failed, isFalse);
        expect(bloc.state.judgingQueue.first.loaded, isNotNull);
      },
    );

    test('dead chat: history loads decrypted, live merges in order, '
        'the optimistic echo of a sent message dedupes', () async {
      final deadChatEvents = StreamController<GameEvent>();
      addTearDown(deadChatEvents.close);
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: deadChatEvents.stream,
        initialEndsAt: endsAt,
      );

      repository.roster = {
        'player-me': await crypto.encryptString('Me'),
        'player-other': await crypto.encryptString('Other'),
      };
      repository.chatHistory = [
        ChatMessageEvent(
          messageId: 'hist-1',
          senderId: 'player-other',
          ciphertext: await crypto.encryptString('hello from history'),
          createdAt: DateTime.utc(2026, 1, 1, 11),
        ),
      ];

      events.add(const GameEvent.youDied(cause: 'mia', survivedSeconds: 42));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.deadChat, hasLength(1));
      expect(bloc.state.deadChat.first.text, 'hello from history');
      expect(bloc.state.deadChat.first.senderName, 'Other');

      repository.nextSendChatId = 'msg-optimistic';
      await bloc.sendChatMessage('hi there');
      expect(bloc.state.deadChat, hasLength(2));
      expect(bloc.state.deadChat.last.text, 'hi there');
      expect(bloc.state.deadChat.last.senderName, 'Me');

      // The live echo of that same send arrives — deduped by message id.
      deadChatEvents.add(
        ChatMessageEvent(
          messageId: 'msg-optimistic',
          senderId: 'player-me',
          ciphertext: repository.sentChatCiphertexts.last,
          createdAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.deadChat, hasLength(2));

      // A genuinely new message from someone else still appends.
      deadChatEvents.add(
        ChatMessageEvent(
          messageId: 'live-1',
          senderId: 'player-other',
          ciphertext: await crypto.encryptString('reply'),
          createdAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.deadChat, hasLength(3));
      expect(bloc.state.deadChat.map((m) => m.id), [
        'hist-1',
        'msg-optimistic',
        'live-1',
      ]);
    });

    test('close() cancels any pending local alarms', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      await bloc.close();

      expect(localAlarms.cancelAllCallCount, 1);
    });

    test('leave() calls leave_active_game and clears the session', () async {
      await session.begin(
        gameId: 'game-1',
        playerId: 'player-me',
        crypto: crypto,
      );
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      await bloc.leave();

      expect(repository.leaveActiveCalled, isTrue);
      expect(session.isActive, isFalse);
    });

    test('leave() clears the session even when the RPC call fails', () async {
      repository.leaveActiveFailure = Exception('offline');
      await session.begin(
        gameId: 'game-1',
        playerId: 'player-me',
        crypto: crypto,
      );
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      await bloc.leave();

      expect(session.isActive, isFalse);
    });

    test('enables the wake lock on construction, keepAwake starts true', () {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      expect(bloc.state.keepAwake, isTrue);
      expect(wakeLockService.enableCallCount, 1);
    });

    test('toggleKeepAwake() flips state and the wake lock each call', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      await bloc.toggleKeepAwake();
      expect(bloc.state.keepAwake, isFalse);
      expect(wakeLockService.disableCallCount, 1);

      await bloc.toggleKeepAwake();
      expect(bloc.state.keepAwake, isTrue);
      expect(wakeLockService.enableCallCount, 2);
    });

    test('close() disables the wake lock', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        localAlarms: localAlarms,
        session: session,
        wakeLockService: wakeLockService,
        gameId: 'game-1',
        myPlayerId: 'player-me',
        deadChatEvents: const Stream<GameEvent>.empty(),
        initialEndsAt: endsAt,
      );

      await bloc.close();

      expect(wakeLockService.disableCallCount, 1);
    });
  });
}
