import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/realtime/game_event.dart';

void main() {
  group('GameEvent.fromBroadcast', () {
    test('decodes player_joined', () {
      final event = GameEvent.fromBroadcast('player_joined', {
        'player_id': 'p-1',
        'name_ciphertext': 'bm9uY2U=',
      });

      expect(
        event,
        const GameEvent.playerJoined(
          playerId: 'p-1',
          nameCiphertext: 'bm9uY2U=',
        ),
      );
    });

    test('falls back to unknown for unmodeled events', () {
      final event = GameEvent.fromBroadcast('brand_new_event', {'x': 1});

      expect(
        event,
        const GameEvent.unknown(event: 'brand_new_event', payload: {'x': 1}),
      );
    });
  });
}
