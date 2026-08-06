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
    // Overridable so tests don't wait 5s — see _restartAfterError.
    Duration retryDelay = const Duration(seconds: 5),
  }) : _repository = repository,
       _gameId = gameId,
       _retryDelay = retryDelay {
    _gameEventsSub = gameEvents.listen(_onEvent);
    _playerEventsSub = playerEvents.listen(_onEvent);
  }

  final GameRepository _repository;
  final String _gameId;
  final Duration _retryDelay;
  Timer? _retryTimer;
  StreamSubscription<Position>? _positionSub;
  late final StreamSubscription<GameEvent> _gameEventsSub;
  late final StreamSubscription<GameEvent> _playerEventsSub;
  DateTime? _lastSentAt;
  bool _stopped = false;

  // Every raw fix, not throttled to the 30s send interval (#65) — the "my
  // location" map wants to feel live, unlike the server, which only needs a
  // fix often enough to catch a rule break.
  final _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  void start() {
    if (_stopped) return;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: _platformSettings(),
    ).listen(_onPosition, onError: (_) => _restartAfterError());
  }

  // A stream error is worse than a missed beat: geolocator never
  // resubscribes an errored stream, so without this a single hiccup would
  // silently end uploads for the rest of the game — the player passes every
  // visible check and is guaranteed an MIA death (#122).
  void _restartAfterError() {
    unawaited(_positionSub?.cancel());
    _positionSub = null;
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, start);
  }

  void _onEvent(GameEvent event) {
    // Either means the rule that binds the living to keep sending is over —
    // #12 would reject a dead sender anyway, this just stops trying.
    if (event is YouDied || event is GameFinished) stop();
  }

  Future<void> _onPosition(Position position) async {
    _positionController.add(position);
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
        // LocationManager, not Google Play Services (#122). The gate's
        // isLocationServiceEnabled() asks LocationManager, but the default
        // fused path re-checks through GMS SettingsClient, which rejects
        // high accuracy whenever "Google Location Accuracy" is off — and
        // with no Activity behind this foreground-service stream that
        // rejection is an instant stream error, not a fix-it dialog. So a
        // player could pass the gate and still never upload a single fix.
        // LocationManager needs no Google consent, matches what the gate
        // verified, and fits the app's no-Google stance.
        forceLocationManager: true,
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
    _retryTimer?.cancel();
    unawaited(_positionSub?.cancel());
    unawaited(_gameEventsSub.cancel());
    unawaited(_playerEventsSub.cancel());
    unawaited(_positionController.close());
  }
}
