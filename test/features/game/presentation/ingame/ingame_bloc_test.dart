import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:framed/features/game/domain/geofence_info.dart';
import 'package:framed/features/game/presentation/ingame/ingame_bloc.dart';
import 'package:framed/features/game/presentation/ingame/ingame_state.dart';

class _FakeGameRepository implements GameRepository {
  Uint8List? selfieBytes;
  Object? failure;

  /// When true, each call parks on its own completer (in call order)
  /// instead of resolving immediately — lets a test control which of two
  /// concurrent downloads "finishes" first.
  bool controlled = false;
  final completers = <Completer<Uint8List>>[];

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
}

void main() {
  group('IngameBloc', () {
    late GameCrypto crypto;
    late _FakeGameRepository repository;
    late StreamController<GameEvent> events;
    late DateTime endsAt;

    setUp(() async {
      crypto = await GameCrypto.generate();
      repository = _FakeGameRepository();
      events = StreamController<GameEvent>();
      endsAt = DateTime.utc(2026, 1, 1, 12);
    });

    tearDown(() => events.close());

    test('starts dispersing at the given endsAt', () {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );

      expect(
        bloc.state,
        IngameState(phase: IngamePhase.dispersing(endsAt: endsAt)),
      );
    });

    test('dispersing -> playing on target_assigned', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
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

    test('unrelated events are ignored', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
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
    });

    test('warning active:false clears the overlay', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
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
    });

    test('compass_pulse sets the snapshot until it expires', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.compassPulse(
          bearingDeg: 42,
          distanceM: 1234,
          expiresAt: DateTime.now().add(const Duration(milliseconds: 50)),
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

    test('an already-expired compass_pulse on arrival is dropped', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );

      events.add(
        GameEvent.compassPulse(
          bearingDeg: 42,
          distanceM: 1234,
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
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
          initialEndsAt: endsAt,
        );

        events.add(
          GameEvent.compassPulse(
            bearingDeg: 1,
            distanceM: 100,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 30)),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        events.add(
          GameEvent.compassPulse(
            bearingDeg: 2,
            distanceM: 200,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 200)),
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
  });
}
