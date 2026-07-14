import 'dart:typed_data';

import '../../../core/realtime/game_event.dart';
import 'geofence_info.dart';

/// Storage + location access for the game feature.
abstract interface class GameRepository {
  /// Downloads the still-encrypted selfie at [path] (`selfies/{game_id}/{player_id}`,
  /// RLS-gated to members of that game) — callers decrypt it with the game key.
  Future<Uint8List> downloadSelfie(String path);

  /// Reports this device's current position. Plaintext server-side by
  /// design — the server enforces the geofence, compass, and staleness with
  /// it (#12). Alive players only, dispersing/active games only.
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  });

  /// The game's play area, for the soft-punishment target map (#18) — the
  /// geofence is set once at host setup and static for the whole game.
  Future<GeofenceInfo> getGeofence(String gameId);

  /// Uploads the already-encrypted frame photo to `frames/{photoPath}`
  /// (#19). Upserts, so a retry after a dropped connection can safely
  /// re-upload to the same path instead of erroring on conflict.
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  });

  /// `submit_frame(game_id, photo_path)` (#19) — the photo must already be
  /// uploaded at that path. Throws [PostgrestException] on any guard
  /// failure; see [FrameError] for the stable codes.
  Future<void> submitFrame({required String gameId, required String photoPath});

  /// Downloads the still-encrypted frame photo at [path]
  /// (`frames/{game_id}/{uuid}`) — callers decrypt it with the game key.
  Future<Uint8List> downloadFramePhoto(String path);

  /// `cast_vote(frame_id, vote)` (#20). A vote on an already-resolved or
  /// voided frame is a silent server-side no-op, not an error.
  Future<void> castVote({required String frameId, required bool vote});

  /// `get_my_state(game_id)` (#53, #54) — a REST snapshot of whatever the
  /// last relevant `player:{id}` broadcast should have told this device
  /// (dispersal end time, current target, or death), shaped identically to
  /// the broadcast payload so it decodes through the same
  /// [GameEvent.fromBroadcast]. The event is null when the server has
  /// nothing further to report (still in the lobby, or active with a
  /// target not assigned yet — shouldn't normally happen). gameStatus is
  /// the routing signal a cold-start resume needs before it even knows
  /// whether to land on the lobby or the ingame screen. nextPulseAt (#73)
  /// is the game's next scheduled compass pulse — null until the game goes
  /// active, independent of which event (if any) this call returns.
  Future<(String gameStatus, GameEvent? event, DateTime? nextPulseAt)>
  getMyState(String gameId);

  /// This game's roster as id → `name_ciphertext` (#24) — dead chat resolves
  /// sender names from it, decrypting with the game key it already has.
  Future<Map<String, String>> getRoster(String gameId);

  /// Dead chat history, oldest first (`chat_dead_select`, #3/#4) — shaped
  /// as [GameEvent.chatMessage] so it decodes through the same path as the
  /// live `game:{game_id}:dead` broadcast.
  Future<List<ChatMessageEvent>> fetchChatHistory(String gameId);

  /// `send_chat(game_id, ciphertext)` (#24) — dead players only, enforced
  /// server-side. Returns the new message's id.
  Future<String> sendChat({required String gameId, required String ciphertext});

  /// This game's mode — the finish screen (#26) needs it to word the
  /// winner line; `game_finished`'s payload doesn't carry it (#25).
  Future<String> getGameMode(String gameId);

  /// The caller's own player id and host flag in [gameId], resolved from
  /// the client's own auth uid — no extra RPC needed (#26).
  Future<(String playerId, bool isHost)> myPlayerInfo(String gameId);

  /// `replay_game(game_id, key_ciphertext)` (#25) — host, finished games
  /// only. Returns the new lobby's game id.
  Future<String> replayGame({
    required String gameId,
    required String keyCiphertext,
  });

  /// Uploads the already-encrypted selfie to `selfies/{path}` for the
  /// replay flow (#26). Unlike the normal join flow's `set_selfie`,
  /// nothing marks it ready here — `rejoinReplay` does that.
  Future<void> uploadReplaySelfie({
    required String path,
    required Uint8List encryptedBytes,
  });

  /// `rejoin_replay(game_id, name_ciphertext, name_hmac)` (#25) — the
  /// selfie must already be uploaded to the caller's canonical path first.
  Future<void> rejoinReplay({
    required String gameId,
    required String nameCiphertext,
    required String nameHmac,
  });

  /// `leave_finished_game(game_id)` (#25).
  Future<void> leaveFinishedGame(String gameId);

  /// Persists an FCM/APNs token rotation (#28) — the caller's own row
  /// only, per the `push_token`-only update grant (11-policies.sql).
  Future<void> updatePushToken({required String gameId, required String token});
}
