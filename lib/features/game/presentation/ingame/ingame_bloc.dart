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
  }) : _crypto = crypto,
       _repository = repository,
       super(
         IngameState(phase: IngamePhase.dispersing(endsAt: initialEndsAt)),
       ) {
    _subscription = events.listen(_onEvent);
  }

  final GameCrypto _crypto;
  final GameRepository _repository;
  late final StreamSubscription<GameEvent> _subscription;

  // Bumped on every target_assigned so an in-flight download/decrypt from a
  // superseded assignment (e.g. a target reassigned after dying) can't land
  // after a newer one already did.
  int _targetGeneration = 0;

  // Same idea for the compass: bumped on every pulse so a stale expiry
  // timer from an earlier pulse can't clear a newer one.
  int _compassGeneration = 0;
  Timer? _compassTimer;

  Future<void> _onEvent(GameEvent event) async {
    if (event is Warning) {
      _onWarning(event);
      return;
    }
    if (event is CompassPulse) {
      _onCompassPulse(event);
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

  @override
  Future<void> close() {
    _subscription.cancel();
    _compassTimer?.cancel();
    return super.close();
  }
}
