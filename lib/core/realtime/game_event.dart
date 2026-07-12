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
        default:
          return GameEvent.unknown(event: event, payload: payload);
      }
    } catch (_) {
      // A malformed payload must never kill an event stream
      return GameEvent.unknown(event: event, payload: payload);
    }
  }
}
