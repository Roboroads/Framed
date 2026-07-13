import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/realtime/game_event.dart';
import '../../domain/game_repository.dart';
import '../../domain/target.dart';
import 'ingame_state.dart';

class IngameBloc extends Cubit<IngameState> {
  IngameBloc({
    required Stream<GameEvent> events,
    required GameCrypto crypto,
    required GameRepository repository,
    required DateTime initialEndsAt,
    // ponytail: no target_location_ended event exists (#13/#18) — the
    // panel expires after this long without a fresh tick instead. Two
    // tick intervals' worth of slack (65-70s against a 30s tick); if this
    // ever proves flaky in practice, add the explicit server event rather
    // than tuning this further. Overridable so tests don't wait 70s.
    Duration targetLocationTimeout = const Duration(seconds: 70),
  }) : _crypto = crypto,
       _repository = repository,
       _targetLocationTimeout = targetLocationTimeout,
       super(
         IngameState(phase: IngamePhase.dispersing(endsAt: initialEndsAt)),
       ) {
    _subscription = events.listen(_onEvent);
  }

  final GameCrypto _crypto;
  final GameRepository _repository;
  final Duration _targetLocationTimeout;
  late final StreamSubscription<GameEvent> _subscription;

  // Bumped on every target_assigned so an in-flight download/decrypt from a
  // superseded assignment (e.g. a target reassigned after dying) can't land
  // after a newer one already did.
  int _targetGeneration = 0;

  // Same idea for the compass: bumped on every pulse so a stale expiry
  // timer from an earlier pulse can't clear a newer one.
  int _compassGeneration = 0;
  Timer? _compassTimer;

  Timer? _targetLocationTimer;

  Future<void> _onEvent(GameEvent event) async {
    if (event is Warning) {
      _onWarning(event);
      return;
    }
    if (event is CompassPulse) {
      _onCompassPulse(event);
      return;
    }
    if (event is TargetLocation) {
      _onTargetLocation(event);
      return;
    }
    if (event is! TargetAssigned) return;
    final generation = ++_targetGeneration;

    try {
      final name = await _crypto.decryptString(event.nameCiphertext);
      final encryptedSelfie = await _repository.downloadSelfie(
        event.selfiePath,
      );
      final selfieBytes = await _crypto.decryptBytes(encryptedSelfie);
      if (isClosed || generation != _targetGeneration) return;
      emit(
        state.copyWith(
          phase: IngamePhase.playing(
            target: Target(
              playerId: event.targetId,
              name: name,
              selfieBytes: selfieBytes,
            ),
          ),
        ),
      );
    } catch (_) {
      if (isClosed || generation != _targetGeneration) return;
      emit(state.copyWith(phase: const IngamePhase.targetLoadFailed()));
    }
  }

  // No local logic decides when a warning starts or stops — this just
  // mirrors the server's `warning` event onto the state.
  void _onWarning(Warning event) {
    emit(
      state.copyWith(
        warning: event.active
            ? IngameWarning(
                reasons: event.reasons,
                hardDeadline: event.hardDeadline!,
              )
            : null,
      ),
    );
  }

  // The client never asks the server when a pulse expires — expiresAt came
  // with the pulse itself, so a local timer clears it right on schedule.
  void _onCompassPulse(CompassPulse event) {
    final generation = ++_compassGeneration;
    _compassTimer?.cancel();

    final remaining = event.expiresAt.difference(DateTime.now());
    // The app may have been closed/backgrounded through the whole pulse —
    // an already-expired snapshot on arrival is simply dropped.
    if (!remaining.isNegative) {
      emit(
        state.copyWith(
          compass: IngameCompass(
            bearingDeg: event.bearingDeg,
            distanceM: event.distanceM,
            expiresAt: event.expiresAt,
            receivedAt: DateTime.now(),
          ),
        ),
      );
      _compassTimer = Timer(remaining, () {
        if (isClosed || generation != _compassGeneration) return;
        emit(state.copyWith(compass: null));
      });
    }
  }

  // No "punishment over" event exists — silence for _targetLocationTimeout
  // is how the panel knows to clear (see the ponytail note on the
  // constructor). Every fresh tick resets the clock.
  void _onTargetLocation(TargetLocation event) {
    _targetLocationTimer?.cancel();
    emit(
      state.copyWith(
        targetLocation: IngameTargetLocation(lat: event.lat, lng: event.lng),
      ),
    );
    _targetLocationTimer = Timer(_targetLocationTimeout, () {
      if (isClosed) return;
      emit(state.copyWith(targetLocation: null));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _compassTimer?.cancel();
    _targetLocationTimer?.cancel();
    return super.close();
  }
}
