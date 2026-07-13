import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/realtime/game_event.dart';
import '../../domain/frame_error.dart';
import '../../domain/game_repository.dart';
import '../../domain/judging_frame.dart';
import '../../domain/target.dart';
import 'ingame_state.dart';

class IngameBloc extends Cubit<IngameState> {
  IngameBloc({
    required Stream<GameEvent> events,
    required GameCrypto crypto,
    required GameRepository repository,
    required String gameId,
    required DateTime initialEndsAt,
    // ponytail: no target_location_ended event exists (#13/#18) — the
    // panel expires after this long without a fresh tick instead. Two
    // tick intervals' worth of slack (65-70s against a 30s tick); if this
    // ever proves flaky in practice, add the explicit server event rather
    // than tuning this further. Overridable so tests don't wait 70s.
    Duration targetLocationTimeout = const Duration(seconds: 70),
  }) : _crypto = crypto,
       _repository = repository,
       _gameId = gameId,
       _targetLocationTimeout = targetLocationTimeout,
       super(
         IngameState(phase: IngamePhase.dispersing(endsAt: initialEndsAt)),
       ) {
    _subscription = events.listen(_onEvent);
    // The one-shot player:{id} broadcast this phase depends on
    // (dispersal_started/target_assigned/you_died) can be missed by a
    // connection that still reports itself joined (#53), or simply never
    // arrive at all on a cold-start resume into a game already in progress
    // (#54). This REST catch-up runs once alongside the live subscription;
    // _phaseGeneration ensures whichever one — this or a live event —
    // starts last wins, same pattern as the target-supersession comment
    // below already relies on.
    unawaited(_fetchCurrentState());
  }

  final GameCrypto _crypto;
  final GameRepository _repository;
  final String _gameId;
  final Duration _targetLocationTimeout;
  late final StreamSubscription<GameEvent> _subscription;
  Timer? _cooldownTimer;

  // Only the queue's front entry is ever loading — set to its frameId so a
  // completion that lands after that entry stopped being the front (voted,
  // cancelled, or overtaken) knows to discard itself instead of writing
  // stale state.
  String? _loadingFrameId;

  // Bumped on every phase-changing event (target_assigned, you_died, the
  // startup catch-up fetch) so an in-flight download/decrypt from a
  // superseded one (e.g. a target reassigned after dying, or a catch-up
  // that resolves after a live event already landed) can't overwrite a
  // newer one that already did.
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
    if (event is GeofenceProximity) {
      emit(state.copyWith(nearGeofenceEdge: event.active));
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
    if (event is FrameVerdict) {
      _onFrameVerdict(event);
      return;
    }
    if (event is FrameToJudge) {
      await _onFrameToJudge(event);
      return;
    }
    if (event is FrameCancelled) {
      _onFrameCancelled(event);
      return;
    }
    if (event is TargetAssigned) {
      await _applyTargetAssigned(event);
      return;
    }
    if (event is YouDied) {
      await _applyYouDied(event);
    }
    // dispersal_started is a game:{game_id} broadcast, never delivered on
    // this bloc's player:{id} subscription — only ever seen via the
    // catch-up fetch below, for a resume that's still mid-dispersal.
  }

  // The REST catch-up counterpart to _onEvent's live handling above —
  // see the constructor comment. get_my_state (#53/#54) returns null only
  // when the server genuinely has nothing to report yet.
  Future<void> _fetchCurrentState() async {
    final generation = ++_targetGeneration;
    GameEvent? event;
    try {
      (_, event) = await _repository.getMyState(_gameId);
    } catch (_) {
      return;
    }
    if (isClosed || generation != _targetGeneration) return;
    switch (event) {
      case TargetAssigned():
        await _applyTargetAssigned(event, generation: generation);
      case YouDied():
        await _applyYouDied(event, generation: generation);
      case DispersalStarted():
        emit(
          state.copyWith(phase: IngamePhase.dispersing(endsAt: event.endsAt)),
        );
      default:
      // No target yet, or an event shape this catch-up doesn't expect —
      // nothing to change.
    }
  }

  Future<void> _applyTargetAssigned(
    TargetAssigned event, {
    int? generation,
  }) async {
    generation ??= ++_targetGeneration;
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

  Future<void> _applyYouDied(YouDied event, {int? generation}) async {
    generation ??= ++_targetGeneration;
    String? killerName;
    if (event.killerNameCiphertext != null) {
      try {
        killerName = await _crypto.decryptString(event.killerNameCiphertext!);
      } catch (_) {
        // A dead player still deserves to see their own death — a killer
        // name that fails to decrypt just renders unattributed.
      }
    }
    Uint8List? photoBytes;
    if (event.photoPath != null) {
      try {
        final encrypted = await _repository.downloadFramePhoto(
          event.photoPath!,
        );
        photoBytes = await _crypto.decryptBytes(encrypted);
      } catch (_) {
        // Same reasoning as the killer name above — a photo that fails to
        // load doesn't block the rest of the death screen from showing.
      }
    }
    if (isClosed || generation != _targetGeneration) return;
    emit(
      state.copyWith(
        phase: IngamePhase.dead(
          cause: event.cause,
          killerName: killerName,
          survivedSeconds: event.survivedSeconds,
          photoBytes: photoBytes,
        ),
      ),
    );
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

  // Encrypts and uploads the photo, then submits the frame. [frameUuid]
  // must stay stable across retries of the same capture — the upload
  // upserts, so a retry after a dropped connection re-uses the same
  // storage path instead of orphaning a partial one (#21).
  Future<FrameError?> submitFrame({
    required Uint8List photoBytes,
    required String frameUuid,
  }) async {
    if (state.frameStatus is! FrameReady) return null;
    try {
      final photoPath = '$_gameId/$frameUuid';
      final encrypted = await _crypto.encryptBytes(photoBytes);
      await _repository.uploadFramePhoto(
        photoPath: photoPath,
        encryptedBytes: encrypted,
      );
      await _repository.submitFrame(gameId: _gameId, photoPath: photoPath);
      if (!isClosed) {
        emit(
          state.copyWith(
            frameStatus: const IngameFrameStatus.waitingForVerdict(),
          ),
        );
      }
      return null;
    } catch (e) {
      return FrameError.fromException(e);
    }
  }

  // A passed verdict just goes back to ready — the target_assigned event
  // that follows (from kill_player's relink) drives the new target card.
  // A failed one starts a cooldown that clears itself on schedule, same
  // idea as the compass expiry timer above.
  void _onFrameVerdict(FrameVerdict event) {
    _cooldownTimer?.cancel();
    final until = event.cooldownUntil;
    if (event.passed || until == null) {
      emit(state.copyWith(frameStatus: const IngameFrameStatus.ready()));
      return;
    }
    emit(state.copyWith(frameStatus: IngameFrameStatus.cooldown(until: until)));
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative) {
      emit(state.copyWith(frameStatus: const IngameFrameStatus.ready()));
      return;
    }
    _cooldownTimer = Timer(remaining, () {
      if (isClosed) return;
      emit(state.copyWith(frameStatus: const IngameFrameStatus.ready()));
    });
  }

  // Just enqueues the raw event — loading (and retrying) only ever
  // happens for whichever entry is currently at the front, see
  // _loadFrontIfNeeded.
  Future<void> _onFrameToJudge(FrameToJudge event) async {
    emit(
      state.copyWith(
        judgingQueue: [
          ...state.judgingQueue,
          IngameJudgingEntry(
            frameId: event.frameId,
            photoPath: event.photoPath,
            targetNameCiphertext: event.targetNameCiphertext,
            targetSelfiePath: event.targetSelfiePath,
          ),
        ],
      ),
    );
    _loadFrontIfNeeded();
  }

  void _onFrameCancelled(FrameCancelled event) {
    emit(
      state.copyWith(
        judgingQueue: state.judgingQueue
            .where((f) => f.frameId != event.frameId)
            .toList(),
      ),
    );
    _loadFrontIfNeeded();
  }

  // One tap, no changing your mind: the frame leaves the queue immediately
  // regardless of what the server does with the vote. A vote that arrives
  // too late is a silent no-op there too (#20) — nothing to reconcile here.
  Future<void> castVote({required String frameId, required bool vote}) async {
    emit(
      state.copyWith(
        judgingQueue: state.judgingQueue
            .where((f) => f.frameId != frameId)
            .toList(),
      ),
    );
    _loadFrontIfNeeded();
    try {
      await _repository.castVote(frameId: frameId, vote: vote);
    } catch (_) {
      // the modal already closed; nothing left to retry against
    }
  }

  // A field with bad signal shouldn't cost a judge their vote — a failed
  // image load keeps its queue slot with [IngameJudgingEntry.failed] set,
  // rather than dropping it, so the modal can offer a retry.
  void retryFrontLoad() => _loadFrontIfNeeded(forceRetry: true);

  void _loadFrontIfNeeded({bool forceRetry = false}) {
    final queue = state.judgingQueue;
    if (queue.isEmpty) return;
    final front = queue.first;
    if (front.loaded != null) return;
    if (front.failed && !forceRetry) return;
    if (_loadingFrameId == front.frameId && !forceRetry) return;

    _loadingFrameId = front.frameId;
    if (front.failed) {
      emit(
        state.copyWith(
          judgingQueue: [front.copyWith(failed: false), ...queue.skip(1)],
        ),
      );
    }
    unawaited(_loadEntry(front));
  }

  Future<void> _loadEntry(IngameJudgingEntry entry) async {
    JudgingFrame? loaded;
    try {
      final targetName = await _crypto.decryptString(
        entry.targetNameCiphertext,
      );
      final encryptedPhoto = await _repository.downloadFramePhoto(
        entry.photoPath,
      );
      final photoBytes = await _crypto.decryptBytes(encryptedPhoto);
      final encryptedSelfie = await _repository.downloadSelfie(
        entry.targetSelfiePath,
      );
      final selfieBytes = await _crypto.decryptBytes(encryptedSelfie);
      loaded = JudgingFrame(
        frameId: entry.frameId,
        photoBytes: photoBytes,
        targetName: targetName,
        targetSelfieBytes: selfieBytes,
      );
    } catch (_) {
      // handled below — loaded stays null, entry gets marked failed
    }
    if (_loadingFrameId == entry.frameId) _loadingFrameId = null;
    if (isClosed) return;

    final queue = state.judgingQueue;
    // The entry may no longer be at the front (voted/cancelled while this
    // was in flight) — or gone entirely. Either way, only write back if
    // it's still exactly where we left it.
    if (queue.isEmpty || queue.first.frameId != entry.frameId) return;
    emit(
      state.copyWith(
        judgingQueue: [
          queue.first.copyWith(loaded: loaded, failed: loaded == null),
          ...queue.skip(1),
        ],
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _compassTimer?.cancel();
    _targetLocationTimer?.cancel();
    _cooldownTimer?.cancel();
    return super.close();
  }
}
