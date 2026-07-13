/// Pure compass geometry (#17) — kept free of widgets so the angle math is
/// directly unit-testable.
library;

/// Degrees to rotate the arrow so it keeps pointing at the fixed world
/// bearing [targetBearingDeg] while the device faces [headingDeg].
/// Normalized to (-180, 180].
double compassArrowAngle({
  required double targetBearingDeg,
  required double headingDeg,
}) {
  var angle = (targetBearingDeg - headingDeg) % 360;
  if (angle > 180) angle -= 360;
  if (angle <= -180) angle += 360;
  return angle;
}

/// Rounded honestly per IDEA.md "The compass": nearest 10 m under 1 km,
/// nearest 100 m at or above.
int roundDistanceMeters(double meters) {
  final step = meters < 1000 ? 10 : 100;
  return (meters / step).round() * step;
}

const _cardinalDirections = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

/// 8-point compass direction for the textual fallback (no heading sensor).
String cardinalDirection(double bearingDeg) {
  final normalized = bearingDeg % 360;
  final index = (normalized / 45).round() % 8;
  return _cardinalDirections[index];
}

/// Accumulates the shortest-path rotation across successive headings, so
/// an [AnimatedRotation]-style widget tweens the short way instead of
/// snapping across the 180°/-180° seam.
class RotationTracker {
  double? _unwrapped;

  /// Feed the next normalized target angle (-180, 180]; returns the
  /// unwrapped angle to actually render (may exceed ±180).
  double update(double targetAngleDeg) {
    final previous = _unwrapped;
    if (previous == null) {
      _unwrapped = targetAngleDeg;
      return targetAngleDeg;
    }
    var delta = (targetAngleDeg - previous) % 360;
    if (delta > 180) delta -= 360;
    if (delta <= -180) delta += 360;
    final next = previous + delta;
    _unwrapped = next;
    return next;
  }
}
