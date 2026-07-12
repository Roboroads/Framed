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

    test('decodes player_ready', () {
      final event = GameEvent.fromBroadcast('player_ready', {
        'player_id': 'p-1',
      });

      expect(event, const GameEvent.playerReady(playerId: 'p-1'));
    });

    test('decodes player_left', () {
      final event = GameEvent.fromBroadcast('player_left', {
        'player_id': 'p-1',
      });

      expect(event, const GameEvent.playerLeft(playerId: 'p-1'));
    });

    test('decodes host_changed', () {
      final event = GameEvent.fromBroadcast('host_changed', {
        'player_id': 'p-2',
      });

      expect(event, const GameEvent.hostChanged(playerId: 'p-2'));
    });

    test('decodes settings_changed', () {
      final event = GameEvent.fromBroadcast('settings_changed', {
        'settings': {'mode': 'last_man_standing', 'disperse_minutes': 12},
      });

      expect(
        event,
        const GameEvent.settingsChanged(
          settings: {'mode': 'last_man_standing', 'disperse_minutes': 12},
        ),
      );
    });

    test('decodes dispersal_started', () {
      final event = GameEvent.fromBroadcast('dispersal_started', {
        'ends_at': '2026-07-12T20:00:00.000Z',
      });

      expect(
        event,
        GameEvent.dispersalStarted(
          endsAt: DateTime.parse('2026-07-12T20:00:00.000Z'),
        ),
      );
    });

    test('decodes target_assigned', () {
      final event = GameEvent.fromBroadcast('target_assigned', {
        'target_id': 't-1',
        'name_ciphertext': 'bm9uY2U=',
        'selfie_path': 'game-1/t-1',
      });

      expect(
        event,
        const GameEvent.targetAssigned(
          targetId: 't-1',
          nameCiphertext: 'bm9uY2U=',
          selfiePath: 'game-1/t-1',
        ),
      );
    });

    test('falls back to unknown for a malformed known event', () {
      final event = GameEvent.fromBroadcast('player_left', {
        'wrong_key': 'oops',
      });

      expect(
        event,
        const GameEvent.unknown(
          event: 'player_left',
          payload: {'wrong_key': 'oops'},
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
