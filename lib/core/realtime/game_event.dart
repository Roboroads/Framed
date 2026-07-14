import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_event.freezed.dart';

/// One event received on a Framed realtime topic.
///
/// The full topic/event catalogue lives in
/// `backend/volumes/db/init/12-realtime.sql`. Variants are added here by the
/// issue that introduces each event; anything not modeled yet decodes as
/// [GameEvent.unknown] so streams never throw on new server events.
@freezed
sealed class GameEvent with _$GameEvent {
  /// game:{game_id} — someone joined the lobby.
  const factory GameEvent.playerJoined({
    required String playerId,
    required String nameCiphertext,
  }) = PlayerJoined;

  /// game:{game_id} — a player's selfie upload completed (set_selfie);
  /// they now count towards the ready total.
  const factory GameEvent.playerReady({required String playerId}) = PlayerReady;

  /// game:{game_id} — someone left the lobby (or was never seated again
  /// after MIA — lobby-only in practice, see leave_lobby).
  const factory GameEvent.playerLeft({required String playerId}) = PlayerLeft;

  /// game:{game_id} — the host left; this player inherited the role.
  const factory GameEvent.hostChanged({required String playerId}) = HostChanged;

  /// game:{game_id} — the host changed the settings. Same shape as
  /// `framed_settings_json` (backend/volumes/db/init/13-lobby.sql).
  const factory GameEvent.settingsChanged({
    required Map<String, dynamic> settings,
  }) = SettingsChanged;

  /// game:{game_id} — the lobby closed; everyone disperses until [endsAt].
  const factory GameEvent.dispersalStarted({required DateTime endsAt}) =
      DispersalStarted;

  /// player:{player_id} — dispersal ended, here is your target.
  const factory GameEvent.targetAssigned({
    required String targetId,
    required String nameCiphertext,
    required String selfiePath,
  }) = TargetAssigned;

  /// player:{player_id} — you're out of the game, framed or MIA.
  const factory GameEvent.youDied({
    required String cause,
    String? killerNameCiphertext,
    String? photoPath,
    required int survivedSeconds,
  }) = YouDied;

  /// player:{player_id} — rule-break state changed (geofence and/or
  /// staleness, see #12/#13). [reasons] and [hardDeadline] are only present
  /// when [active] is true.
  const factory GameEvent.warning({
    required bool active,
    @Default([]) List<String> reasons,
    DateTime? hardDeadline,
  }) = Warning;

  /// player:{player_id} — still inside the geofence but close to leaving it
  /// (#61), a heads-up before [warning] (with reason `geofence`) would ever
  /// fire. Distinct event on purpose: warning means a punishment clock is
  /// already running, this doesn't.
  const factory GameEvent.geofenceProximity({required bool active}) =
      GeofenceProximity;

  /// player:{player_id} — the global compass pulse's snapshot for this
  /// player (#16), a bearing/distance pair valid until [expiresAt].
  const factory GameEvent.compassPulse({
    required double bearingDeg,
    required double distanceM,
    required DateTime expiresAt,
  }) = CompassPulse;

  /// player:{assassin_id} — the target's exact location, sent every tick
  /// while they're soft-punished (#13, #18). No expiry field — the client
  /// infers "punishment over" from silence (see IngameBloc).
  const factory GameEvent.targetLocation({
    required double lat,
    required double lng,
  }) = TargetLocation;

  /// player:{judge_id} — a frame awaiting your vote (#19). Fanned out to
  /// every player but the assassin and the target, alive or dead.
  const factory GameEvent.frameToJudge({
    required String frameId,
    required String photoPath,
    required String targetNameCiphertext,
    required String targetSelfiePath,
  }) = FrameToJudge;

  /// player:{judge_id} — a frame you hadn't voted on (or whose outcome your
  /// vote no longer affects) was voided before it resolved (#20).
  const factory GameEvent.frameCancelled({required String frameId}) =
      FrameCancelled;

  /// player:{assassin_id} — the verdict on your one open frame (#20).
  /// [cooldownUntil] is only present when [passed] is false.
  const factory GameEvent.frameVerdict({
    required bool passed,
    DateTime? cooldownUntil,
  }) = FrameVerdict;

  /// game:{game_id} — the game is over.
  const factory GameEvent.gameFinished({
    required String winnerId,
    required Map<String, dynamic> stats,
    required List<dynamic> killChain,
  }) = GameFinished;

  /// game:{game_id} — the host started a replay with the same players
  /// (#25, #26). Every member's client (host included) handles this the
  /// same way: decrypt the new key, refresh identity, land in the new
  /// lobby.
  const factory GameEvent.replayStarted({
    required String newGameId,
    required String keyCiphertext,
    required String joinToken,
  }) = ReplayStarted;

  /// game:{game_id}:dead — a dead player sent a chat message (#24). Also
  /// reused (like [GameEvent.fromBroadcast] itself) to shape
  /// GameRepository.fetchChatHistory's REST rows identically to the live
  /// broadcast.
  const factory GameEvent.chatMessage({
    required String messageId,
    required String senderId,
    required String ciphertext,
    required DateTime createdAt,
  }) = ChatMessageEvent;

  /// Fallback for events this app version does not model (yet).
  const factory GameEvent.unknown({
    required String event,
    required Map<String, dynamic> payload,
  }) = UnknownGameEvent;

  factory GameEvent.fromBroadcast(String event, Map<String, dynamic> payload) {
    try {
      switch (event) {
        case 'player_joined':
          return GameEvent.playerJoined(
            playerId: payload['player_id'] as String,
            nameCiphertext: payload['name_ciphertext'] as String,
          );
        case 'player_ready':
          return GameEvent.playerReady(
            playerId: payload['player_id'] as String,
          );
        case 'player_left':
          return GameEvent.playerLeft(playerId: payload['player_id'] as String);
        case 'host_changed':
          return GameEvent.hostChanged(
            playerId: payload['player_id'] as String,
          );
        case 'settings_changed':
          return GameEvent.settingsChanged(
            settings: Map<String, dynamic>.from(payload['settings'] as Map),
          );
        case 'dispersal_started':
          return GameEvent.dispersalStarted(
            endsAt: DateTime.parse(payload['ends_at'] as String),
          );
        case 'target_assigned':
          return GameEvent.targetAssigned(
            targetId: payload['target_id'] as String,
            nameCiphertext: payload['name_ciphertext'] as String,
            selfiePath: payload['selfie_path'] as String,
          );
        case 'you_died':
          return GameEvent.youDied(
            cause: payload['cause'] as String,
            killerNameCiphertext: payload['killer_name_ciphertext'] as String?,
            photoPath: payload['photo_path'] as String?,
            survivedSeconds: payload['survived_seconds'] as int,
          );
        case 'warning':
          return GameEvent.warning(
            active: payload['active'] as bool,
            reasons: payload['reasons'] != null
                ? List<String>.from(payload['reasons'] as List)
                : const [],
            hardDeadline: payload['hard_deadline'] != null
                ? DateTime.parse(payload['hard_deadline'] as String)
                : null,
          );
        case 'geofence_proximity':
          return GameEvent.geofenceProximity(active: payload['active'] as bool);
        case 'compass_pulse':
          return GameEvent.compassPulse(
            bearingDeg: (payload['bearing_deg'] as num).toDouble(),
            distanceM: (payload['distance_m'] as num).toDouble(),
            expiresAt: DateTime.parse(payload['expires_at'] as String),
          );
        case 'target_location':
          return GameEvent.targetLocation(
            lat: (payload['lat'] as num).toDouble(),
            lng: (payload['lng'] as num).toDouble(),
          );
        case 'frame_to_judge':
          return GameEvent.frameToJudge(
            frameId: payload['frame_id'] as String,
            photoPath: payload['photo_path'] as String,
            targetNameCiphertext: payload['target_name_ciphertext'] as String,
            targetSelfiePath: payload['target_selfie_path'] as String,
          );
        case 'frame_cancelled':
          return GameEvent.frameCancelled(
            frameId: payload['frame_id'] as String,
          );
        case 'frame_verdict':
          return GameEvent.frameVerdict(
            passed: payload['passed'] as bool,
            cooldownUntil: payload['cooldown_until'] != null
                ? DateTime.parse(payload['cooldown_until'] as String)
                : null,
          );
        case 'game_finished':
          return GameEvent.gameFinished(
            winnerId: payload['winner_id'] as String,
            stats: Map<String, dynamic>.from(payload['stats'] as Map),
            killChain: List<dynamic>.from(payload['kill_chain'] as List),
          );
        case 'replay_started':
          return GameEvent.replayStarted(
            newGameId: payload['new_game_id'] as String,
            keyCiphertext: payload['key_ciphertext'] as String,
            joinToken: payload['join_token'] as String,
          );
        case 'chat_message':
          return GameEvent.chatMessage(
            messageId: payload['message_id'] as String,
            senderId: payload['sender_id'] as String,
            ciphertext: payload['ciphertext'] as String,
            createdAt: DateTime.parse(payload['created_at'] as String),
          );
        default:
          return GameEvent.unknown(event: event, payload: payload);
      }
    } catch (_) {
      // A malformed payload must never kill an event stream
      return GameEvent.unknown(event: event, payload: payload);
    }
  }
}
