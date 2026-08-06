import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/location/location_service.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

/// Records submitted locations; everything else is unreachable from
/// [LocationService].
class _FakeGameRepository implements GameRepository {
  final locations = <(double, double)>[];

  @override
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  }) async {
    locations.add((lat, lng));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Hands out one fresh controller per getPositionStream call, so a test can
/// fail the first subscription and then feed the second.
class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  final controllers = <StreamController<Position>>[];

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    final controller = StreamController<Position>();
    controllers.add(controller);
    return controller.stream;
  }
}

Position _position(double lat, double lng) => Position(
  latitude: lat,
  longitude: lng,
  timestamp: DateTime.now(),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  group('LocationService', () {
    late _FakeGameRepository repository;
    late _FakeGeolocatorPlatform platform;

    setUp(() {
      repository = _FakeGameRepository();
      platform = _FakeGeolocatorPlatform();
      GeolocatorPlatform.instance = platform;
    });

    LocationService buildService({
      Duration retryDelay = const Duration(milliseconds: 20),
    }) => LocationService(
      repository: repository,
      gameId: 'game-1',
      gameEvents: const Stream<GameEvent>.empty(),
      playerEvents: const Stream<GameEvent>.empty(),
      retryDelay: retryDelay,
    );

    test('positions reach the repository', () async {
      buildService().start();

      platform.controllers.single.add(_position(1, 2));
      await Future<void>.delayed(Duration.zero);

      expect(repository.locations, [(1.0, 2.0)]);
    });

    // #122: one stream error used to kill uploads for the rest of the game
    // — silently, with the player still passing every visible check. An
    // errored stream must come back on its own.
    test('resubscribes after a position stream error', () async {
      buildService().start();
      expect(platform.controllers, hasLength(1));

      platform.controllers[0].addError(Exception('gms rejected'));
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(platform.controllers, hasLength(2));
      platform.controllers[1].add(_position(3, 4));
      await Future<void>.delayed(Duration.zero);

      expect(repository.locations, [(3.0, 4.0)]);
    });

    test('stop() cancels a pending resubscribe', () async {
      final service = buildService()..start();

      platform.controllers[0].addError(Exception('gms rejected'));
      service.stop();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(platform.controllers, hasLength(1));
    });

    test('you_died stops the stream for good, even through a retry', () async {
      final playerEvents = StreamController<GameEvent>.broadcast();
      final service = LocationService(
        repository: repository,
        gameId: 'game-1',
        gameEvents: const Stream<GameEvent>.empty(),
        playerEvents: playerEvents.stream,
        retryDelay: const Duration(milliseconds: 20),
      )..start();
      addTearDown(playerEvents.close);
      addTearDown(service.stop);

      platform.controllers[0].addError(Exception('gms rejected'));
      playerEvents.add(
        const GameEvent.youDied(cause: 'mia', survivedSeconds: 60),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(platform.controllers, hasLength(1));
    });
  });
}
