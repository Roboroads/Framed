import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/chat/chat_limits.dart';
import '../../../../core/chat/chat_message.dart';
import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../domain/game_repository.dart';
import 'finish_state.dart';

/// The finish screen's state machine (#26): decrypts the `game_finished`
/// payload it's constructed with, then — for the finished game's
/// `game:{game_id}` topic — watches for `replay_started` and runs the
/// replay handshake identically whether this device is the host (who just
/// triggered it) or anyone else.
class FinishBloc extends Cubit<FinishState> {
  FinishBloc({
    required GameFinished initialEvent,
    required Stream<GameEvent> gameEvents,
    // game:{game_id}:dead (#79) — open to everyone once the game's
    // finished, not just players who died (framed_can_chat,
    // 11-policies.sql), so the whole group can coordinate a meetup.
    required Stream<GameEvent> deadChatEvents,
    required GameCrypto crypto,
    required GameRepository repository,
    required GameSession session,
    required String gameId,
  }) : _crypto = crypto,
       _repository = repository,
       _session = session,
       _gameId = gameId,
       super(const FinishState()) {
    _subscription = gameEvents.listen(_onEvent);
    _chatSubscription = deadChatEvents.listen(_onChatEvent);
    unawaited(_init(initialEvent));
  }

  final GameCrypto _crypto;
  final GameRepository _repository;
  final GameSession _session;
  final String _gameId;
  late final StreamSubscription<GameEvent> _subscription;
  late final StreamSubscription<GameEvent> _chatSubscription;

  // Resolved during _init — needed to tell "own row" apart from the rest
  // during the replay handshake (own name/selfie source path), and to
  // label this device's own outgoing chat messages.
  String? _myPlayerId;

  // id -> decrypted display name (#79), same resolve-once pattern as
  // IngameBloc's dead chat — built from the same roster fetch _init
  // already does for stats/kill-chain, so no second round trip.
  final Map<String, String> _resolvedNames = {};

  Future<void> _init(GameFinished event) async {
    try {
      final roster = await _repository.getRoster(_gameId);
      final names = <String, String>{};
      for (final entry in roster.entries) {
        try {
          names[entry.key] = await _crypto.decryptString(entry.value);
        } catch (_) {
          // That sender's name falls back to their raw id below.
        }
      }
      _resolvedNames.addAll(names);

      final mode = await _repository.getGameMode(_gameId);
      final (myPlayerId, isHost) = await _repository.myPlayerInfo(_gameId);
      _myPlayerId = myPlayerId;

      final playersRaw = (event.stats['players'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final stats = [
        for (final p in playersRaw)
          FinishStat(
            playerId: p['player_id'] as String,
            name: names[p['player_id']] ?? p['player_id'] as String,
            kills: p['kills'] as int,
            distanceMovedM: (p['distance_moved_m'] as num).toDouble(),
            stillSeconds: p['still_seconds'] as int,
          ),
      ];

      final killChain = [
        for (final raw in event.killChain)
          _killChainEntry(Map<String, dynamic>.from(raw as Map), names),
      ];

      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          winnerId: event.winnerId,
          winnerName: names[event.winnerId] ?? event.winnerId,
          youWon: event.winnerId == myPlayerId,
          mode: mode,
          stats: stats,
          totalDistanceMovedM: (event.stats['total_distance_moved_m'] as num)
              .toDouble(),
          durationSeconds: event.stats['duration_seconds'] as int,
          killChain: killChain,
          isHost: isHost,
        ),
      );
    } catch (_) {
      // The screen still renders — matches the tolerant-decrypt pattern
      // used elsewhere (ingame_bloc.dart) rather than getting stuck.
      if (isClosed) return;
      emit(state.copyWith(loading: false));
    }
    unawaited(_loadChatHistory());
  }

  // Best-effort (#79) — same reasoning as IngameBloc._startDeadChat: the
  // live subscription (already listening since the constructor) still
  // works even if history fails to load, chat just starts empty.
  Future<void> _loadChatHistory() async {
    try {
      final history = await _repository.fetchChatHistory(_gameId);
      final messages = [
        for (final row in history) await _decryptChatMessage(row),
      ];
      if (!isClosed) emit(state.copyWith(chat: messages));
    } catch (_) {}
  }

  FinishKillChainEntry _killChainEntry(
    Map<String, dynamic> k,
    Map<String, String> names,
  ) {
    final killerId = k['killer_id'] as String?;
    return FinishKillChainEntry(
      victimName: names[k['victim_id']] ?? k['victim_id'] as String,
      killerName: killerId == null ? null : names[killerId] ?? killerId,
      cause: k['cause'] as String,
    );
  }

  void _onEvent(GameEvent event) {
    if (event is ReplayStarted) unawaited(_onReplayStarted(event));
  }

  void _onChatEvent(GameEvent event) {
    if (event is! ChatMessageEvent) return;
    unawaited(_appendChatMessage(event));
  }

  Future<void> _appendChatMessage(ChatMessageEvent event) async {
    if (state.chat.any((m) => m.id == event.messageId)) return;
    final message = await _decryptChatMessage(event);
    if (isClosed) return;
    // Re-check after the await — the optimistic echo in sendChatMessage
    // (or another concurrent append) may have landed while this decrypted.
    if (state.chat.any((m) => m.id == message.id)) return;
    emit(state.copyWith(chat: [...state.chat, message]));
  }

  Future<ChatMessage> _decryptChatMessage(ChatMessageEvent event) async {
    String text;
    try {
      text = await _crypto.decryptString(event.ciphertext);
    } catch (_) {
      text = '';
    }
    return ChatMessage(
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
    final myPlayerId = _myPlayerId;
    if (myPlayerId == null) return; // _init hasn't resolved yet
    try {
      final ciphertext = await _crypto.encryptString(trimmed);
      final id = await _repository.sendChat(
        gameId: _gameId,
        ciphertext: ciphertext,
      );
      if (isClosed || state.chat.any((m) => m.id == id)) return;
      emit(
        state.copyWith(
          chat: [
            ...state.chat,
            ChatMessage(
              id: id,
              senderId: myPlayerId,
              senderName: _resolvedNames[myPlayerId] ?? myPlayerId,
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

  // Host-initiated: a fresh key, encrypted under the old one so the server
  // never sees it in plaintext. This device's own swap happens uniformly
  // through _onReplayStarted below, same as everyone else's — no
  // special-casing the host's own broadcast.
  Future<void> startReplay() async {
    if (!state.isHost || state.replayStatus == FinishReplayStatus.working) {
      return;
    }
    emit(state.copyWith(replayStatus: FinishReplayStatus.working));
    try {
      final newCrypto = await GameCrypto.generate();
      final keyCiphertext = await _crypto.encrypt(await newCrypto.keyBytes);
      await _repository.replayGame(
        gameId: _gameId,
        keyCiphertext: keyCiphertext,
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(replayStatus: FinishReplayStatus.error));
    }
  }

  Future<void> _onReplayStarted(ReplayStarted event) async {
    final myPlayerId = _myPlayerId;
    if (myPlayerId == null) return; // _init hasn't resolved yet — shouldn't
    // happen in practice (game_finished always precedes replay_started by
    // as long as it takes a human to tap a button), but there's nothing to
    // refresh without it.
    emit(state.copyWith(replayStatus: FinishReplayStatus.working));
    try {
      final newCrypto = await GameCrypto.fromKeyBytes(
        await _crypto.decrypt(event.keyCiphertext),
      );
      final (newPlayerId, _) = await _repository.myPlayerInfo(event.newGameId);

      final myOldNameCiphertext = (await _repository.getRoster(
        _gameId,
      ))[myPlayerId];
      final plainName = myOldNameCiphertext == null
          ? ''
          : await _crypto.decryptString(myOldNameCiphertext);
      final newNameCiphertext = await newCrypto.encryptString(plainName);
      final newNameHmac = await newCrypto.nameHmac(plainName);

      final encryptedSelfie = await _repository.downloadSelfie(
        '$_gameId/$myPlayerId',
      );
      final plainSelfie = await _crypto.decryptBytes(encryptedSelfie);
      final reEncryptedSelfie = await newCrypto.encryptBytes(plainSelfie);
      await _repository.uploadReplaySelfie(
        path: '${event.newGameId}/$newPlayerId',
        encryptedBytes: reEncryptedSelfie,
      );

      await _repository.rejoinReplay(
        gameId: event.newGameId,
        nameCiphertext: newNameCiphertext,
        nameHmac: newNameHmac,
      );

      await _session.begin(
        gameId: event.newGameId,
        playerId: newPlayerId,
        crypto: newCrypto,
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          replayStatus: FinishReplayStatus.idle,
          replayReadyGameId: event.newGameId,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(replayStatus: FinishReplayStatus.error));
    }
  }

  Future<void> leave() async {
    try {
      await _repository.leaveFinishedGame(_gameId);
    } catch (_) {
      // Best-effort, same reasoning as LobbyBloc.leave(): the player still
      // wants out even if the network call failed.
    }
    await _session.end();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _chatSubscription.cancel();
    return super.close();
  }
}
