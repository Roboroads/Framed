import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'game_event.dart';

/// Subscriptions to Framed's three private broadcast topics.
///
/// The server is the only emitter; clients just decode what arrives. Topic
/// authorization is enforced server-side by RLS on realtime.messages
/// (backend/volumes/db/init/12-realtime.sql).
class GameChannels {
  GameChannels(this._client);

  final SupabaseClient _client;

  /// game:{game_id} — lobby and game-wide events, all players.
  Stream<GameEvent> game(String gameId) => _topic('game:$gameId');

  /// player:{player_id} — events for one player only.
  Stream<GameEvent> player(String playerId) => _topic('player:$playerId');

  Stream<GameEvent> _topic(String topic) {
    final controller = StreamController<GameEvent>();
    RealtimeChannel? channel;
    controller.onListen = () {
      try {
        channel =
            _client.channel(
                topic,
                opts: const RealtimeChannelConfig(private: true),
              )
              ..onBroadcast(
                event: '*',
                callback: (envelope) {
                  controller.add(
                    GameEvent.fromBroadcast(
                      envelope['event'] as String,
                      Map<String, dynamic>.from(
                        envelope['payload'] as Map? ?? {},
                      ),
                    ),
                  );
                },
              )
              ..subscribe((status, error) {
                // Surface refused joins etc. instead of hanging silently
                if (error != null && !controller.isClosed) {
                  controller.addError(error);
                }
              });
      } catch (e, st) {
        controller.addError(e, st);
      }
    };
    controller.onCancel = () async {
      final c = channel;
      if (c != null) await _client.removeChannel(c);
    };
    return controller.stream;
  }
}
