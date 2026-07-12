import 'package:flutter_test/flutter_test.dart';
import 'package:framed/features/lobby/domain/game_mode.dart';
import 'package:framed/features/lobby/domain/game_settings.dart';

void main() {
  group('GameSettings.toJson', () {
    test('uses the backend column names and wire values', () {
      const settings = GameSettings(
        mode: GameMode.lastManStanding,
        geofenceLat: 52.09,
        geofenceLng: 5.12,
        geofenceRadiusM: 300,
        disperseMinutes: 15,
        softPunishmentMinutes: 3,
        hardPunishmentMinutes: 6,
        compassUpdateIntervalMinutes: 12,
        compassViewSeconds: 20,
        voteTimeoutMinutes: 4,
        frameCooldownMinutes: 7,
      );

      expect(settings.toJson(), {
        'mode': 'last_man_standing',
        'geofence_lat': 52.09,
        'geofence_lng': 5.12,
        'geofence_radius_m': 300,
        'disperse_minutes': 15,
        'soft_punishment_minutes': 3,
        'hard_punishment_minutes': 6,
        'compass_update_interval_minutes': 12,
        'compass_view_seconds': 20,
        'vote_timeout_minutes': 4,
        'frame_cooldown_minutes': 7,
      });
    });

    test('defaults match IDEA.md "Game options"', () {
      const settings = GameSettings(geofenceLat: 0, geofenceLng: 0);

      expect(settings.mode, GameMode.mostFrames);
      expect(settings.disperseMinutes, 10);
      expect(settings.softPunishmentMinutes, 2);
      expect(settings.hardPunishmentMinutes, 5);
      expect(settings.compassUpdateIntervalMinutes, 10);
      expect(settings.compassViewSeconds, 30);
      expect(settings.voteTimeoutMinutes, 5);
      expect(settings.frameCooldownMinutes, 5);
    });
  });
}
