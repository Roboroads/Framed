import 'package:freezed_annotation/freezed_annotation.dart';

part 'finish_state.freezed.dart';

/// One player's row from `game_finished`'s `stats.players` (#25), decrypted.
@freezed
sealed class FinishStat with _$FinishStat {
  const factory FinishStat({
    required String playerId,
    required String name,
    required int kills,
    required double distanceMovedM,
    required int stillSeconds,
    required int survivedSeconds,
  }) = _FinishStat;
}

/// One death from `game_finished`'s `kill_chain` (#25), decrypted and in
/// death order. [killerName] is null for a `mia` entry.
@freezed
sealed class FinishKillChainEntry with _$FinishKillChainEntry {
  const factory FinishKillChainEntry({
    required String victimName,
    String? killerName,
    required String cause,
    required DateTime diedAt,
  }) = _FinishKillChainEntry;
}

/// The replay handshake's progress (#26) — [FinishReplayStatus.working]
/// covers everything from the host's tap (or another member's
/// `replay_started` arriving) through landing in the new lobby.
enum FinishReplayStatus { idle, working, error }

/// One decrypted chat message (#79) — same shape and channel as the
/// ingame death screen's chat, just open to everyone here since the game's
/// already over. [senderName] is already resolved from the roster.
@freezed
sealed class FinishChatMessage with _$FinishChatMessage {
  const factory FinishChatMessage({
    required String id,
    required String senderId,
    required String senderName,
    required String text,
    required DateTime createdAt,
  }) = _FinishChatMessage;
}

@freezed
sealed class FinishState with _$FinishState {
  const factory FinishState({
    // True until _init's roster/mode/stat decrypt finishes — every other
    // field below is meaningless until then.
    @Default(true) bool loading,
    @Default('') String winnerId,
    @Default('') String winnerName,
    @Default(false) bool youWon,
    @Default('most_frames') String mode,
    @Default([]) List<FinishStat> stats,
    @Default(0) double totalDistanceMovedM,
    @Default(0) int durationSeconds,
    @Default([]) List<FinishKillChainEntry> killChain,
    @Default(false) bool isHost,
    @Default(FinishReplayStatus.idle) FinishReplayStatus replayStatus,
    // Set once this device has fully swapped into the new game (crypto,
    // session, identity refreshed) — the page navigates to /lobby on it.
    String? replayReadyGameId,
    // Oldest first (#79), history + live merged.
    @Default([]) List<FinishChatMessage> chat,
  }) = _FinishState;
}
