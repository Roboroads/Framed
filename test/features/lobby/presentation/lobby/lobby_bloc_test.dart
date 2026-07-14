import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/core/session/session_store.dart';
import 'package:framed/features/lobby/domain/game_mode.dart';
import 'package:framed/features/lobby/domain/game_settings.dart';
import 'package:framed/features/lobby/domain/lobby_repository.dart';
import 'package:framed/features/lobby/domain/lobby_roster_entry.dart';
import 'package:framed/features/lobby/domain/lobby_snapshot.dart';
import 'package:framed/features/lobby/presentation/lobby/lobby_bloc.dart';
import 'package:framed/features/lobby/presentation/lobby/lobby_state.dart';
import 'package:latlong2/latlong.dart';

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
  LobbySnapshot? snapshot;
  Object? loadFailure;
  Object? startFailure;
  String? leftGameId;
  Map<String, dynamic>? capturedSettings;
  int startGameCallCount = 0;
  int heartbeatCallCount = 0;
  Object? heartbeatFailure;

  /// When set, `fetchLobby` parks on this instead of resolving immediately —
  /// lets a test fire realtime events while the initial load is in flight.
  Completer<LobbySnapshot>? fetchGate;

  @override
  Future<LobbySnapshot> fetchLobby(String gameId) {
    if (loadFailure != null) throw loadFailure!;
    final gate = fetchGate;
    return gate != null ? gate.future : Future.value(snapshot!);
  }

  @override
  Future<void> startGame(String gameId) async {
    startGameCallCount++;
    if (startFailure != null) throw startFailure!;
  }

  @override
  Future<void> heartbeat(String gameId) async {
    heartbeatCallCount++;
    if (heartbeatFailure != null) throw heartbeatFailure!;
  }

  @override
  Future<void> updateSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) async {
    capturedSettings = settings;
  }

  @override
  Future<void> leaveLobby(String gameId) async {
    leftGameId = gameId;
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
  Future<(String, String)> joinGame({
    required String joinToken,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) => throw UnimplementedError();

  @override
  Future<String> myHostPlayerId(String gameId) => throw UnimplementedError();

  @override
  Future<void> uploadSelfie({
    required String gameId,
    required String playerId,
    required Uint8List encryptedSelfie,
  }) => throw UnimplementedError();
}

void main() {
  group('LobbyBloc', () {
    const gameId = 'game-1';
    late GameCrypto crypto;
    late _FakeLobbyRepository repository;
    late StreamController<GameEvent> events;

    LobbySnapshot snapshotWith({
      String hostPlayerId = 'player-host',
      List<LobbyRosterEntry> roster = const [],
    }) => LobbySnapshot(
      hostPlayerId: hostPlayerId,
      joinToken: 'token-1',
      mode: GameMode.mostFrames,
      disperseMinutes: 10,
      softPunishmentMinutes: 2,
      hardPunishmentMinutes: 5,
      compassUpdateIntervalMinutes: 10,
      compassViewSeconds: 30,
      voteTimeoutMinutes: 5,
      frameCooldownMinutes: 5,
      geofenceRadiusM: 200,
      geofenceLat: 52.0907,
      geofenceLng: 5.1214,
      roster: roster,
    );

    GameSession sessionAs(String playerId) =>
        GameSession(SessionStore(_FakeSecureKeyValueStore()))
          ..begin(gameId: gameId, playerId: playerId, crypto: crypto);

    setUp(() async {
      crypto = await GameCrypto.generate();
      repository = _FakeLobbyRepository();
      events = StreamController<GameEvent>();
    });

    tearDown(() => events.close());

    test('loads the initial snapshot, decrypting names', () async {
      repository.snapshot = snapshotWith(
        hostPlayerId: 'player-host',
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
        ],
      );

      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.phase, LobbyPhase.ready);
      expect(bloc.state.roster, [
        const LobbyPlayer(id: 'player-host', name: 'Alice', hasSelfie: true),
      ]);
      expect(bloc.state.hostPlayerId, 'player-host');
      expect(bloc.isHost, isTrue);
    });

    test('an event that arrives while the initial snapshot is still loading '
        'is not lost once the snapshot lands', () async {
      repository.snapshot = snapshotWith(
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
        ],
      );
      repository.fetchGate = Completer<LobbySnapshot>();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );

      // A player joins before the initial fetch resolves.
      events.add(
        GameEvent.playerJoined(
          playerId: 'player-2',
          nameCiphertext: await crypto.encryptString('Bob'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.phase, LobbyPhase.loading);

      repository.fetchGate!.complete(repository.snapshot);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.phase, LobbyPhase.ready);
      expect(bloc.state.roster.map((p) => p.id), ['player-host', 'player-2']);
    });

    test('player_joined appends a not-yet-ready player', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      events.add(
        GameEvent.playerJoined(
          playerId: 'player-2',
          nameCiphertext: await crypto.encryptString('Bob'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.roster, [
        const LobbyPlayer(id: 'player-2', name: 'Bob', hasSelfie: false),
      ]);
      expect(bloc.state.readyCount, 0);
    });

    test('player_ready marks only that player ready', () async {
      repository.snapshot = snapshotWith(
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
          LobbyRosterEntry(
            playerId: 'player-2',
            nameCiphertext: await crypto.encryptString('Bob'),
            hasSelfie: false,
          ),
        ],
      );
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      events.add(const GameEvent.playerReady(playerId: 'player-2'));
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.roster.firstWhere((p) => p.id == 'player-2').hasSelfie,
        isTrue,
      );
      expect(
        bloc.state.roster.firstWhere((p) => p.id == 'player-host').hasSelfie,
        isTrue,
      );
      expect(bloc.state.readyCount, 2);
    });

    test('player_left removes that player', () async {
      repository.snapshot = snapshotWith(
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
          LobbyRosterEntry(
            playerId: 'player-2',
            nameCiphertext: await crypto.encryptString('Bob'),
            hasSelfie: true,
          ),
        ],
      );
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      events.add(const GameEvent.playerLeft(playerId: 'player-2'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.roster.map((p) => p.id), ['player-host']);
    });

    test(
      'host_changed promotes the new host — controls appear for them live',
      () async {
        repository.snapshot = snapshotWith(hostPlayerId: 'player-host');
        final bloc = LobbyBloc(
          repository: repository,
          session: sessionAs('player-2'),
          events: events.stream,
          gameId: gameId,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(bloc.isHost, isFalse);

        events.add(const GameEvent.hostChanged(playerId: 'player-2'));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.hostPlayerId, 'player-2');
        expect(bloc.isHost, isTrue);
      },
    );

    test('settings_changed updates the mode live', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.mode, GameMode.mostFrames);

      events.add(
        const GameEvent.settingsChanged(
          settings: {'mode': 'last_man_standing'},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.mode, GameMode.lastManStanding);
    });

    test('changeMode sends the new mode to the repository', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.changeMode(GameMode.lastManStanding);

      expect(repository.capturedSettings, {'mode': 'last_man_standing'});
    });

    test(
      'changeGeofenceRadius sends the new radius to the repository',
      () async {
        repository.snapshot = snapshotWith();
        final bloc = LobbyBloc(
          repository: repository,
          session: sessionAs('player-host'),
          events: events.stream,
          gameId: gameId,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await bloc.changeGeofenceRadius(500);

        expect(repository.capturedSettings, {'geofence_radius_m': 500});
      },
    );

    test('settings_changed updates the geofence radius live', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.geofenceRadiusM, 200);

      events.add(
        const GameEvent.settingsChanged(settings: {'geofence_radius_m': 500}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.geofenceRadiusM, 500);
    });

    test(
      'changeGeofenceCenter sends the new center to the repository',
      () async {
        repository.snapshot = snapshotWith();
        final bloc = LobbyBloc(
          repository: repository,
          session: sessionAs('player-host'),
          events: events.stream,
          gameId: gameId,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await bloc.changeGeofenceCenter(const LatLng(52.5, 4.9));

        expect(repository.capturedSettings, {
          'geofence_lat': 52.5,
          'geofence_lng': 4.9,
        });
      },
    );

    test('settings_changed updates the geofence center live', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.geofenceLat, 52.0907);
      expect(bloc.state.geofenceLng, 5.1214);

      events.add(
        const GameEvent.settingsChanged(
          settings: {'geofence_lat': 52.5, 'geofence_lng': 4.9},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.geofenceLat, 52.5);
      expect(bloc.state.geofenceLng, 4.9);
    });

    test('canStart flips true only once 3 players are ready', () async {
      repository.snapshot = snapshotWith(
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
          LobbyRosterEntry(
            playerId: 'player-2',
            nameCiphertext: await crypto.encryptString('Bob'),
            hasSelfie: true,
          ),
        ],
      );
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.canStart, isFalse);

      events.add(
        GameEvent.playerJoined(
          playerId: 'player-3',
          nameCiphertext: await crypto.encryptString('Cara'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.canStart, isFalse);

      events.add(const GameEvent.playerReady(playerId: 'player-3'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.canStart, isTrue);
    });

    test('dispersal_started sets dispersalEndsAt', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final endsAt = DateTime.utc(2026, 1, 1, 12);

      events.add(GameEvent.dispersalStarted(endsAt: endsAt));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.dispersalEndsAt, endsAt);
    });

    test('start() is a no-op below the ready-player minimum', () async {
      repository.snapshot = snapshotWith(
        roster: [
          LobbyRosterEntry(
            playerId: 'player-host',
            nameCiphertext: await crypto.encryptString('Alice'),
            hasSelfie: true,
          ),
        ],
      );
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.start();

      expect(repository.startGameCallCount, 0);
    });

    test('a start() failure resets starting and surfaces an error', () async {
      repository.snapshot = snapshotWith(
        roster: [
          for (final id in ['player-host', 'player-2', 'player-3'])
            LobbyRosterEntry(
              playerId: id,
              nameCiphertext: await crypto.encryptString(id),
              hasSelfie: true,
            ),
        ],
      );
      repository.startFailure = Exception('network is down');
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.start();

      expect(repository.startGameCallCount, 1);
      expect(bloc.state.starting, isFalse);
      expect(bloc.state.error, isNotNull);
    });

    test('leave() calls leave_lobby and clears the session', () async {
      repository.snapshot = snapshotWith();
      final session = sessionAs('player-host');
      final bloc = LobbyBloc(
        repository: repository,
        session: session,
        events: events.stream,
        gameId: gameId,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await bloc.leave();

      expect(repository.leftGameId, gameId);
      expect(session.isActive, isFalse);
    });

    test('sends an immediate heartbeat on construction', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
      );
      addTearDown(bloc.close);
      await Future<void>.delayed(Duration.zero);

      expect(repository.heartbeatCallCount, 1);
    });

    test('sends a heartbeat on every timer tick', () async {
      repository.snapshot = snapshotWith();
      final bloc = LobbyBloc(
        repository: repository,
        session: sessionAs('player-host'),
        events: events.stream,
        gameId: gameId,
        heartbeatInterval: const Duration(milliseconds: 20),
      );
      addTearDown(bloc.close);
      await Future<void>.delayed(Duration.zero); // the immediate ping

      await Future<void>.delayed(const Duration(milliseconds: 70));

      // Immediate ping + at least 2 ticks in 70ms at a 20ms interval;
      // exact tick count is timing-sensitive, only the lower bound isn't.
      expect(repository.heartbeatCallCount, greaterThanOrEqualTo(3));
    });
  });
}
