import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  }) : _repository = repository,
       _session = session,
       super(const LobbyState()) {
    _subscription = events.listen(_onEvent);
    _load();
  }

  final LobbyRepository _repository;
  final GameSession _session;
  final String gameId;
  late final StreamSubscription<GameEvent> _subscription;

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

  Future<void> leave() async {
    await _repository.leaveLobby(gameId);
    _session.end();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
