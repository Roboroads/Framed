import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import '../../domain/lobby_roster_entry.dart';
import 'lobby_state.dart';

class LobbyBloc extends Cubit<LobbyState> {
  LobbyBloc({
    required LobbyRepository repository,
    required GameSession session,
    required Stream<GameEvent> events,
    required this.gameId,
    // Well under the 15-minute per-player expiry (26-lobby-expiry.sql) —
    // a couple of missed pings from a flaky connection still land inside
    // the window. Overridable so tests don't wait 5 minutes.
    Duration heartbeatInterval = const Duration(minutes: 5),
  }) : _repository = repository,
       _session = session,
       super(const LobbyState()) {
    _subscription = events.listen(_onEvent);
    _load();
    // Immediate first ping, not just the periodic one below — last_seen
    // otherwise only refreshes at join time, which can already be stale
    // by the time a resumed session lands back on this screen.
    unawaited(_sendHeartbeat());
    _heartbeatTimer = Timer.periodic(
      heartbeatInterval,
      (_) => unawaited(_sendHeartbeat()),
    );
  }

  final LobbyRepository _repository;
  final GameSession _session;
  final String gameId;
  late final StreamSubscription<GameEvent> _subscription;
  late final Timer _heartbeatTimer;

  // Events can arrive on the socket while _load()'s fetch is still in
  // flight; applying them immediately against the pre-snapshot (empty)
  // state would just get clobbered when the snapshot lands and overwrites
  // roster/settings wholesale. Buffer until the snapshot is in, then replay.
  final _pendingEvents = <GameEvent>[];
  bool _loaded = false;

  String get myPlayerId => _session.playerId;

  bool get isHost => state.hostPlayerId == myPlayerId;

  GameCrypto get _crypto => _session.crypto;

  // The page can be popped (close()) while an RPC or a decrypt is still
  // in flight — Cubit.emit() throws StateError once closed, so every
  // async emit() in this bloc is guarded.
  void _safeEmit(LobbyState next) {
    if (!isClosed) emit(next);
  }

  Future<void> _load() async {
    try {
      final snapshot = await _repository.fetchLobby(gameId);
      final roster = await Future.wait(snapshot.roster.map(_decrypt));
      _safeEmit(
        state.copyWith(
          phase: LobbyPhase.ready,
          roster: roster,
          hostPlayerId: snapshot.hostPlayerId,
          joinToken: snapshot.joinToken,
          mode: snapshot.mode,
          disperseMinutes: snapshot.disperseMinutes,
          softPunishmentMinutes: snapshot.softPunishmentMinutes,
          hardPunishmentMinutes: snapshot.hardPunishmentMinutes,
          compassUpdateIntervalMinutes: snapshot.compassUpdateIntervalMinutes,
          compassViewSeconds: snapshot.compassViewSeconds,
          voteTimeoutMinutes: snapshot.voteTimeoutMinutes,
          frameCooldownMinutes: snapshot.frameCooldownMinutes,
          geofenceRadiusM: snapshot.geofenceRadiusM,
          geofenceLat: snapshot.geofenceLat,
          geofenceLng: snapshot.geofenceLng,
        ),
      );
      _loaded = true;
      final pending = List<GameEvent>.of(_pendingEvents);
      _pendingEvents.clear();
      for (final event in pending) {
        await _applyEvent(event);
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          phase: LobbyPhase.error,
          error: LobbyError.fromException(e),
        ),
      );
    }
  }

  Future<LobbyPlayer> _decrypt(LobbyRosterEntry entry) async {
    return LobbyPlayer(
      id: entry.playerId,
      name: await _crypto.decryptString(entry.nameCiphertext),
      hasSelfie: entry.hasSelfie,
    );
  }

  Future<void> _onEvent(GameEvent event) async {
    if (!_loaded) {
      _pendingEvents.add(event);
      return;
    }
    try {
      await _applyEvent(event);
    } catch (_) {
      // One player's corrupted/tampered ciphertext must not take down the
      // whole roster feed for everyone else — skip just this update.
    }
  }

  Future<void> _applyEvent(GameEvent event) async {
    switch (event) {
      case PlayerJoined(:final playerId, :final nameCiphertext):
        // The snapshot query and this event can race and both capture the
        // same join — don't double them up.
        if (state.roster.any((p) => p.id == playerId)) return;
        final name = await _crypto.decryptString(nameCiphertext);
        _safeEmit(
          state.copyWith(
            roster: [
              ...state.roster,
              LobbyPlayer(id: playerId, name: name, hasSelfie: false),
            ],
          ),
        );
      case PlayerReady(:final playerId):
        _safeEmit(
          state.copyWith(
            roster: [
              for (final p in state.roster)
                if (p.id == playerId) p.copyWith(hasSelfie: true) else p,
            ],
          ),
        );
      case PlayerLeft(:final playerId):
        _safeEmit(
          state.copyWith(
            roster: state.roster.where((p) => p.id != playerId).toList(),
          ),
        );
      case HostChanged(:final playerId):
        _safeEmit(state.copyWith(hostPlayerId: playerId));
      case SettingsChanged(:final settings):
        _safeEmit(_withSettings(settings));
      case DispersalStarted(:final endsAt):
        _safeEmit(state.copyWith(dispersalEndsAt: endsAt));
      default:
        return;
    }
  }

  LobbyState _withSettings(Map<String, dynamic> settings) {
    var next = state;
    if (settings['mode'] case final String mode) {
      next = next.copyWith(mode: GameMode.fromWireValue(mode));
    }
    if (settings['disperse_minutes'] case final int v) {
      next = next.copyWith(disperseMinutes: v);
    }
    if (settings['soft_punishment_minutes'] case final int v) {
      next = next.copyWith(softPunishmentMinutes: v);
    }
    if (settings['hard_punishment_minutes'] case final int v) {
      next = next.copyWith(hardPunishmentMinutes: v);
    }
    if (settings['compass_update_interval_minutes'] case final int v) {
      next = next.copyWith(compassUpdateIntervalMinutes: v);
    }
    if (settings['compass_view_seconds'] case final int v) {
      next = next.copyWith(compassViewSeconds: v);
    }
    if (settings['vote_timeout_minutes'] case final int v) {
      next = next.copyWith(voteTimeoutMinutes: v);
    }
    if (settings['frame_cooldown_minutes'] case final int v) {
      next = next.copyWith(frameCooldownMinutes: v);
    }
    if (settings['geofence_radius_m'] case final int v) {
      next = next.copyWith(geofenceRadiusM: v);
    }
    if (settings['geofence_lat'] case final num v) {
      next = next.copyWith(geofenceLat: v.toDouble());
    }
    if (settings['geofence_lng'] case final num v) {
      next = next.copyWith(geofenceLng: v.toDouble());
    }
    return next;
  }

  Future<void> changeMode(GameMode mode) async {
    // supabase_flutter's rpc() builder is lazy — it only actually sends the
    // request once awaited. _showModePicker's onChanged callback discards
    // this method's returned future, so the await must happen in here.
    await _repository.updateSettings(
      gameId: gameId,
      settings: {'mode': mode.wireValue},
    );
  }

  // Game settings screen (#62) — same one-field-per-call shape as
  // changeMode, one call per editable field, key at the call site (#93:
  // was seven near-identical methods, one per field name; the keys are
  // already stringly-typed inside the settings map either way, so the
  // only thing actually lost by collapsing them is autocomplete). The
  // geofence center still isn't a free-placement picker (#43 — no
  // drag-to-move on the map); the one way to move it is
  // changeGeofenceCenter below, an explicit re-center on the host's
  // current GPS fix (#71).
  //
  // Must await internally, same reason as changeMode: the callers
  // (Slider.onChanged, IconButton.onPressed) all discard the returned
  // future, and supabase_flutter's rpc() builder is lazy — it never
  // actually sends unless something awaits it. A first cut of these as
  // tail-call expression bodies (`=> _repository.updateSettings(...)`)
  // reached this method, returned a future nobody awaited, and silently
  // never sent the request — caught live: the mode change (which already
  // awaited) landed in the database, the radius/timing changes didn't.
  Future<void> changeSetting(String key, Object value) async {
    await _repository.updateSettings(gameId: gameId, settings: {key: value});
  }

  Future<void> changeGeofenceRadius(int radiusM) async {
    await _repository.updateSettings(
      gameId: gameId,
      settings: {'geofence_radius_m': radiusM},
    );
  }

  Future<void> changeGeofenceCenter(LatLng center) async {
    await _repository.updateSettings(
      gameId: gameId,
      settings: {
        'geofence_lat': center.latitude,
        'geofence_lng': center.longitude,
      },
    );
  }

  Future<void> start() async {
    if (!state.canStart) return;
    _safeEmit(state.copyWith(starting: true, error: null));
    try {
      await _repository.startGame(gameId);
      // No local phase change here — dispersal_started (already subscribed
      // to) is what actually moves everyone on, host included.
    } catch (e) {
      _safeEmit(
        state.copyWith(starting: false, error: LobbyError.fromException(e)),
      );
    }
  }

  // Best-effort (#70) — a missed ping just means the next one, on the
  // regular timer, is what keeps this player's last_seen current.
  Future<void> _sendHeartbeat() async {
    try {
      await _repository.heartbeat(gameId);
    } catch (_) {}
  }

  Future<void> leave() async {
    await _repository.leaveLobby(gameId);
    await _session.end();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _heartbeatTimer.cancel();
    return super.close();
  }
}
