import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/location/compass_math.dart';

void main() {
  group('compassArrowAngle', () {
    test('target dead ahead when bearing equals heading', () {
      expect(
        compassArrowAngle(targetBearingDeg: 90, headingDeg: 90),
        closeTo(0, 1e-9),
      );
    });

    test('target to the right rotates the arrow clockwise', () {
      expect(
        compassArrowAngle(targetBearingDeg: 90, headingDeg: 0),
        closeTo(90, 1e-9),
      );
    });

    test('normalizes across the 0/360 seam', () {
      expect(
        compassArrowAngle(targetBearingDeg: 10, headingDeg: 350),
        closeTo(20, 1e-9),
      );
    });

    test('normalizes to (-180, 180] instead of e.g. 270', () {
      expect(
        compassArrowAngle(targetBearingDeg: 0, headingDeg: 90),
        closeTo(-90, 1e-9),
      );
    });

    test('rotating the device the opposite way of the target', () {
      final before = compassArrowAngle(targetBearingDeg: 45, headingDeg: 0);
      // Device turns 30 degrees clockwise (heading increases) — the
      // world-fixed target should appear to rotate counterclockwise.
      final after = compassArrowAngle(targetBearingDeg: 45, headingDeg: 30);
      expect(after, lessThan(before));
      expect(after, closeTo(before - 30, 1e-9));
    });
  });

  group('roundDistanceMeters', () {
    test('rounds to the nearest 10 m under 1 km', () {
      expect(roundDistanceMeters(343), 340);
      expect(roundDistanceMeters(345), 350);
    });

    test('rounds to the nearest 100 m at or above 1 km', () {
      expect(roundDistanceMeters(1249), 1200);
      expect(roundDistanceMeters(1250), 1300);
    });
  });

  group('cardinalDirection', () {
    test('maps bearings to the nearest of 8 points', () {
      expect(cardinalDirection(0), 'N');
      expect(cardinalDirection(44), 'NE');
      expect(cardinalDirection(90), 'E');
      expect(cardinalDirection(180), 'S');
      expect(cardinalDirection(315), 'NW');
      expect(cardinalDirection(359), 'N');
    });
  });

  group('RotationTracker', () {
    test('first update returns the angle unchanged', () {
      final tracker = RotationTracker();
      expect(tracker.update(45), 45);
    });

    test('takes the short way across the 180/-180 seam', () {
      final tracker = RotationTracker();
      tracker.update(170);
      // Jumping to -170 is only 20 degrees away going through 180, not 340
      // degrees back through 0.
      final next = tracker.update(-170);
      expect(next, closeTo(190, 1e-9));
    });

    test('accumulates across multiple short hops', () {
      final tracker = RotationTracker();
      tracker.update(0);
      tracker.update(90);
      final next = tracker.update(170);
      expect(next, closeTo(170, 1e-9));
    });
  });
}
