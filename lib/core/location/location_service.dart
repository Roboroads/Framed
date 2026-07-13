import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

import '../../features/game/domain/game_repository.dart';
import '../../i18n/strings.g.dart';
import '../realtime/game_event.dart';

const _updateInterval = Duration(seconds: 30);

/// Streams this device's position to the server every 30 seconds, from
/// dispersal start until death or game finish (IDEA.md "Game rules") — the
/// riskiest client feature in the MVP (IDEA.md "Known risks").
///
/// A missed beat is tolerated by design — the server's stale threshold is
/// 90 seconds, three missed updates. No retry queue: a failed send is
/// dropped, not buffered. Only last-known location matters; a buffered old
/// fix is worse than none.
class LocationService {
  LocationService({
    required GameRepository repository,
    required String gameId,
    required Stream<GameEvent> gameEvents,
    required Stream<GameEvent> playerEvents,
  }) : _repository = repository,
       _gameId = gameId {
    _gameEventsSub = gameEvents.listen(_onEvent);
    _playerEventsSub = playerEvents.listen(_onEvent);
  }

  final GameRepository _repository;
  final String _gameId;
  StreamSubscription<Position>? _positionSub;
  late final StreamSubscription<GameEvent> _gameEventsSub;
  late final StreamSubscription<GameEvent> _playerEventsSub;
  DateTime? _lastSentAt;
  bool _stopped = false;

  void start() {
    if (_stopped) return;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: _platformSettings(),
    ).listen(_onPosition, onError: (_) {});
  }

  void _onEvent(GameEvent event) {
    // Either means the rule that binds the living to keep sending is over —
    // #12 would reject a dead sender anyway, this just stops trying.
    if (event is YouDied || event is GameFinished) stop();
  }

  Future<void> _onPosition(Position position) async {
    final now = DateTime.now();
    if (_lastSentAt != null && now.difference(_lastSentAt!) < _updateInterval) {
      return;
    }
    _lastSentAt = now;
    try {
      await _repository.submitLocation(
        gameId: _gameId,
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {
      // Dropped, not buffered — the next position heals it.
    }
  }

  LocationSettings _platformSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        intervalDuration: _updateInterval,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: t.location.notificationTitle,
          notificationText: t.location.notificationText,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings();
  }

  void stop() {
    if (_stopped) return;
    _stopped = true;
    unawaited(_positionSub?.cancel());
    unawaited(_gameEventsSub.cancel());
    unawaited(_playerEventsSub.cancel());
  }
}
