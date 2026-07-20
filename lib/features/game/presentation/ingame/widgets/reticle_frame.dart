import 'package:flutter/material.dart';

/// Four corner brackets drawn just inside [child] — the viewfinder the app is
/// named for, wrapped around the one person you're here to use it on. The
/// target sits in the mark's own sights: this is the thing you *frame*.
///
/// Butt caps and mitre joins, like every stroke in the reticle — no round
/// corner anywhere, so it reads as machined chrome over the photo rather than
/// as a decorative border.
class ReticleFrame extends StatelessWidget {
  const ReticleFrame({
    required this.child,
    required this.color,
    this.arm = 24,
    this.inset = 8,
    this.stroke = 2.5,
    super.key,
  });

  final Widget child;
  final Color color;

  /// Length of each corner bracket's two legs.
  final double arm;

  /// How far the brackets sit in from the child's edge.
  final double inset;

  final double stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BracketPainter(
        color: color,
        arm: arm,
        inset: inset,
        stroke: stroke,
      ),
      child: child,
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({
    required this.color,
    required this.arm,
    required this.inset,
    required this.stroke,
  });

  final Color color;
  final double arm;
  final double inset;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    final rect = (Offset.zero & size).deflate(inset);
    // (corner x, corner y, x-direction, y-direction) for each of the four.
    for (final (x, y, sx, sy) in [
      (rect.left, rect.top, 1.0, 1.0),
      (rect.right, rect.top, -1.0, 1.0),
      (rect.right, rect.bottom, -1.0, -1.0),
      (rect.left, rect.bottom, 1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x + sx * arm, y)
          ..lineTo(x, y)
          ..lineTo(x, y + sy * arm),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.color != color ||
      old.arm != arm ||
      old.inset != inset ||
      old.stroke != stroke;
}
