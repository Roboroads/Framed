/// Renders a duration as `'{h}h {m}m'`, or just `'{m}m'` under an hour
/// (#102) -- shared by the death screen's "survived for" line and the
/// finish screen's game-duration line, which used to hand-roll the same
/// formatting twice.
String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}
