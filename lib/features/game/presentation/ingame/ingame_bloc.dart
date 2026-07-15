import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/chat/chat_limits.dart';
import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/location/wake_lock_service.dart';
import '../../../../core/push/local_alarms.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
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
    required LocalAlarms localAlarms,
    required GameSession session,
    required WakeLockService wakeLockService,
    // game:{game_id}:dead (#24) — unlike [events], not joined until this
    // player actually dies (RLS refuses the subscribe before then; see
    // _startDeadChat), same lazy-join-on-listen behaviour as GameChannels.
    required Stream<GameEvent> deadChatEvents,
    required String gameId,
    required String myPlayerId,
    required DateTime initialEndsAt,
    // ponytail: no target_location_ended event exists (#13/#18) — the
    // panel expires after this long without a fresh tick instead. Two
    // tick intervals' worth of slack (65-70s against a 30s tick); if this
    // ever proves flaky in practice, add the explicit server event rather
    // than tuning this further. Overridable so tests don't wait 70s.
    Duration targetLocationTimeout = const Duration(seconds: 70),
    // A full tick cycle (30s) past a warning's hard_deadline, plus slack
    // (#74) — see _onWarning. Overridable so tests don't wait 35s.
    Duration warningResyncGrace = const Duration(seconds: 35),
  }) : _crypto = crypto,
       _repository = repository,
       _localAlarms = localAlarms,
       _session = session,
       _wakeLockService = wakeLockService,
       _deadChatEvents = deadChatEvents,
       _gameId = gameId,
       _myPlayerId = myPlayerId,
       _targetLocationTimeout = targetLocationTimeout,
       _warningResyncGrace = warningResyncGrace,
       super(
         IngameState(phase: IngamePhase.dispersing(endsAt: initialEndsAt)),
       ) {
    _subscription = events.listen(_onEvent);
    // Default on (#78) — see IngameState.keepAwake.
    unawaited(_wakeLockService.enable());
    // The one-shot player:{id} broadcast this phase depends on
    // (dispersal_started/target_assigned/you_died) can be missed by a
    // connection that still reports itself joined (#53), or simply never
    // arrive at all on a cold-start resume into a game already in progress
    // (#54). This REST catch-up runs once alongside the live subscription;
    // _phaseGeneration ensures whichever one — this or a live event —
    // starts last wins, same pattern as the target-supersession comment
    // below already relies on.
    unawaited(_fetchCurrentState());
    // The self-name label (#73) — no plaintext name lives in GameSession
    // (only the id), so this decrypts it from the roster the same way dead
    // chat already resolves sender names.
    unawaited(_fetchMyName());
  }

  final GameCrypto _crypto;
  final GameRepository _repository;
  final LocalAlarms _localAlarms;
  final GameSession _session;
  final WakeLockService _wakeLockService;
  final Stream<GameEvent> _deadChatEvents;
  final String _gameId;
  final String _myPlayerId;
  final Duration _targetLocationTimeout;
  final Duration _warningResyncGrace;
  late final StreamSubscription<GameEvent> _subscription;
  Timer? _cooldownTimer;

  // Set once, the first time this player dies (_startDeadChat) — null
  // guards against double-subscribing, since both the live you_died path
  // and the catch-up path can reach death.
  StreamSubscription<GameEvent>? _chatSubscription;
  // id -> decrypted display name, built once from the roster (#24). A
  // sender not found here (roster fetch failed, or hasn't loaded yet)
  // falls back to their raw id rather than blocking the message.
  final Map<String, String> _resolvedNames = {};

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

  // Self-heal (#74) for a warning countdown that reaches its deadline with
  // no resolution: rescheduled on every warning update (live or caught up),
  // cancelled once the rule-break clears or this player dies either way.
  Timer? _warningResyncTimer;

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
    MyStateResult result;
    try {
      result = await _repository.getMyState(_gameId);
    } catch (_) {
      return;
    }
    if (isClosed || generation != _targetGeneration) return;
    if (result.nextPulseAt case final nextPulseAt?) {
      emit(state.copyWith(nextPulseAt: nextPulseAt));
      unawaited(_localAlarms.scheduleCompassPulse(nextPulseAt));
    }
    if (result.activeWarning case Warning warning) _onWarning(warning);
    switch (result.event) {
      case TargetAssigned event:
        await _applyTargetAssigned(event, generation: generation);
      case YouDied event:
        await _applyYouDied(event, generation: generation);
      case DispersalStarted(:final endsAt):
        emit(state.copyWith(phase: IngamePhase.dispersing(endsAt: endsAt)));
      case GameFinished event:
        // #89: the game ended without this page ever seeing the live
        // game:{game_id} broadcast — set the backstop for IngamePage's own
        // listener to navigate away with, same as that broadcast would.
        emit(state.copyWith(pendingFinish: event));
      default:
      // No target yet, or an event shape this catch-up doesn't expect —
      // nothing to change.
    }
  }

  // Best-effort — a name that fails to resolve just means the label stays
  // hidden (see _fetchMyName's caller). No dependency on _targetGeneration:
  // this never competes with a target/death update, it just adds a field.
  Future<void> _fetchMyName() async {
    try {
      final roster = await _repository.getRoster(_gameId);
      final ciphertext = roster[_myPlayerId];
      if (ciphertext == null) return;
      final name = await _crypto.decryptString(ciphertext);
      if (!isClosed) emit(state.copyWith(myName: name));
    } catch (_) {
      // Nothing to fall back to — the label just doesn't render.
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
    _warningResyncTimer?.cancel();
    unawaited(_localAlarms.cancelAll());
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
        keepAwake: false,
      ),
    );
    // The wake lock (#78) exists so a compass pulse or warning is never
    // missed to a dimmed screen — dead players get neither. A pending
    // frame_to_judge still wakes the device via its own push, same as any
    // other push while the game's still active.
    unawaited(_wakeLockService.disable());
    unawaited(_startDeadChat());
    unawaited(_loadOtherDeadPlayers());
  }

  // Best-effort (#80), same reasoning as _startDeadChat: a failure just
  // means the list stays empty, nothing else on the death screen depends
  // on it.
  Future<void> _loadOtherDeadPlayers() async {
    try {
      final deadPlayers = await _repository.getDeadPlayers(_gameId);
      final names = <String>[];
      for (final entry in deadPlayers.entries) {
        if (entry.key == _myPlayerId) continue;
        try {
          names.add(await _crypto.decryptString(entry.value));
        } catch (_) {
          // That one player's name is skipped rather than shown raw —
          // unlike chat senders, there's no id fallback slot in this list.
        }
      }
      if (!isClosed) emit(state.copyWith(otherDeadPlayerNames: names));
    } catch (_) {}
  }

  // Dead chat (#24): joins game:{game_id}:dead (only possible now that this
  // player is actually dead — RLS refuses the subscribe otherwise), then
  // loads the roster and history. The live subscription starts first so no
  // message sent between "died" and "history loaded" is missed.
  Future<void> _startDeadChat() async {
    if (_chatSubscription != null) return;
    _chatSubscription = _deadChatEvents.listen(_onChatEvent);
    try {
      final roster = await _repository.getRoster(_gameId);
      for (final entry in roster.entries) {
        try {
          _resolvedNames[entry.key] = await _crypto.decryptString(entry.value);
        } catch (_) {
          // That one sender's messages fall back to their raw id below.
        }
      }
      final history = await _repository.fetchChatHistory(_gameId);
      final messages = [
        for (final row in history) await _decryptChatMessage(row),
      ];
      if (!isClosed) emit(state.copyWith(deadChat: messages));
    } catch (_) {
      // The live subscription above still works even if history/roster
      // failed to load — chat from here on just starts with an empty list.
    }
  }

  void _onChatEvent(GameEvent event) {
    if (event is! ChatMessageEvent) return;
    unawaited(_appendChatMessage(event));
  }

  Future<void> _appendChatMessage(ChatMessageEvent event) async {
    if (state.deadChat.any((m) => m.id == event.messageId)) return;
    final message = await _decryptChatMessage(event);
    if (isClosed) return;
    // Re-check after the await — the optimistic echo in sendChatMessage
    // (or another concurrent append) may have landed while this decrypted.
    if (state.deadChat.any((m) => m.id == message.id)) return;
    emit(state.copyWith(deadChat: [...state.deadChat, message]));
  }

  Future<IngameChatMessage> _decryptChatMessage(ChatMessageEvent event) async {
    String text;
    try {
      text = await _crypto.decryptString(event.ciphertext);
    } catch (_) {
      text = '';
    }
    return IngameChatMessage(
      id: event.messageId,
      senderId: event.senderId,
      senderName: _resolvedNames[event.senderId] ?? event.senderId,
      text: text,
      createdAt: event.createdAt,
    );
  }

  // Optimistic append: the message is on screen before its own broadcast
  // echoes back over game:{game_id}:dead. _appendChatMessage's id dedupe
  // discards that echo when it arrives.
  Future<void> sendChatMessage(String text) async {
    var trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > maxChatMessageLength) {
      trimmed = trimmed.substring(0, maxChatMessageLength);
    }
    try {
      final ciphertext = await _crypto.encryptString(trimmed);
      final id = await _repository.sendChat(
        gameId: _gameId,
        ciphertext: ciphertext,
      );
      if (isClosed || state.deadChat.any((m) => m.id == id)) return;
      emit(
        state.copyWith(
          deadChat: [
            ...state.deadChat,
            IngameChatMessage(
              id: id,
              senderId: _myPlayerId,
              senderName: _resolvedNames[_myPlayerId] ?? _myPlayerId,
              text: trimmed,
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );
    } catch (_) {
      // Nothing to reconcile — the composer just keeps the user's draft.
    }
  }

  // Leave button, alive or dead (#77) — `leave_active_game` kills an
  // alive caller server-side (cause 'left') exactly like any other death,
  // and just marks left_at for one already dead. Same best-effort shape
  // as LobbyBloc/FinishBloc.leave(): the player still wants out even if
  // the network call failed. Unlike those two, the confirmation dialog
  // here promises an immediate, deterministic consequence ("this ends the
  // game if it drops the player count below 3"), so callers (#88) surface
  // the returned success flag instead of assuming it always held.
  Future<bool> leave() async {
    var succeeded = true;
    try {
      await _repository.leaveActiveGame(_gameId);
    } catch (_) {
      succeeded = false;
    }
    await _session.end();
    return succeeded;
  }

  // Quick on/off (#78) — no persistence across sessions by design, every
  // game starts with the screen kept awake and a player opts out fresh
  // each time rather than carrying a stale preference from a past game.
  Future<void> toggleKeepAwake() async {
    final next = !state.keepAwake;
    emit(state.copyWith(keepAwake: next));
    await (next ? _wakeLockService.enable() : _wakeLockService.disable());
  }

  // No local logic decides when a warning starts or stops — this just
  // mirrors the server's `warning` event onto the state. Also feeds
  // get_my_state's active_warning catch-up (#74), same shape, same
  // handling either way.
  void _onWarning(Warning event) {
    _warningResyncTimer?.cancel();
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
    if (!event.active) {
      unawaited(_localAlarms.cancelWarningDeadline());
      return;
    }
    unawaited(_localAlarms.scheduleWarningDeadline(event.hardDeadline!));

    // If the deadline passes with no you_died and no fresh warning update
    // at all, tick_punishments may have silently stopped running for this
    // game (e.g. a held lock) — re-ask the server directly instead of
    // trusting a countdown that might just be stuck at 00:00. Grace period
    // is a full tick cycle (30s) past the deadline plus slack, so this
    // never fires before the next regular tick's own live update would
    // have resolved it naturally.
    final untilDeadline = event.hardDeadline!.difference(DateTime.now());
    final delay =
        (untilDeadline.isNegative ? Duration.zero : untilDeadline) +
        _warningResyncGrace;
    _warningResyncTimer = Timer(delay, () {
      if (!isClosed) unawaited(_fetchCurrentState());
    });
  }

  // The client never asks the server when a pulse expires — expiresAt came
  // with the pulse itself, so a local timer clears it right on schedule.
  void _onCompassPulse(CompassPulse event) {
    final generation = ++_compassGeneration;
    _compassTimer?.cancel();

    // Unlike compass below, nextPulseAt (#73) isn't cleared by the expiry
    // timer — it's the countdown to show once the arrow disappears, not
    // part of the snapshot that disappears.
    emit(state.copyWith(nextPulseAt: event.nextPulseAt));
    unawaited(_localAlarms.scheduleCompassPulse(event.nextPulseAt));

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
    emit(
      state.copyWith(
        frameStatus: IngameFrameStatus.cooldown(
          until: until,
          reason: event.reason,
        ),
      ),
    );
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
    _chatSubscription?.cancel();
    _compassTimer?.cancel();
    _targetLocationTimer?.cancel();
    _cooldownTimer?.cancel();
    _warningResyncTimer?.cancel();
    unawaited(_localAlarms.cancelAll());
    unawaited(_wakeLockService.disable());
    return super.close();
  }
}
