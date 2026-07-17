import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The game's own iconography, derived from one motif: the viewfinder's four
/// corner brackets — the same shape as the app icon, which is a crosshair and
/// a picture frame at the same time.
///
/// Drawn rather than bundled. These are geometry, not illustration: painting
/// them keeps every glyph crisp at any size, inherits [IconTheme] color and
/// size like a real [Icon], and costs no assets. Material icons stay in use
/// everywhere the meaning is generic (close, language, back) — this set only
/// covers the five ideas that are Framed's own.
enum FramedIcon {
  /// The bare motif: four brackets, nothing inside. A housing to put
  /// something else in — see [FramedIcon.compass].
  reticle,

  /// Your target. Brackets closing on a subject.
  target,

  /// Take the shot / a submitted frame photo.
  frame,

  /// The pulse needle: which way your target was at pulse time.
  ///
  /// Deliberately just the needle, with no brackets of its own. This icon
  /// spins — it's the one thing on screen tracking the device compass — and
  /// a viewfinder that rotates with it would read as the world tilting.
  /// Stack it inside a static [FramedIcon.reticle] to get the full compass.
  compass,

  /// The play area you have to stay inside.
  geofence,

  /// A rule-break, warning, or punishment. The frame breaks open.
  warning,
}

/// Draws a [FramedIcon] at the ambient [IconTheme]'s size and color, so it
/// drops into `Icon`'s place anywhere — including as a `Button.icon` child.
class FramedIcons extends StatelessWidget {
  const FramedIcons(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final FramedIcon icon;
  final double? size;
  final Color? color;

  /// Mirrors [Icon.semanticLabel]: null for icons a nearby label already
  /// names, a string for icons carrying meaning on their own.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolved = size ?? iconTheme.size ?? 24.0;
    final painted = SizedBox.square(
      dimension: resolved,
      child: CustomPaint(
        painter: _FramedIconPainter(
          icon: icon,
          color:
              color ??
              iconTheme.color ??
              Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
    if (semanticLabel == null) return painted;
    return Semantics(label: semanticLabel, child: painted);
  }
}

class _FramedIconPainter extends CustomPainter {
  const _FramedIconPainter({required this.icon, required this.color});

  final FramedIcon icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything is authored on a 24-unit grid — the same grid Material's
    // icons use — then scaled, so line weight stays proportional.
    final s = size.width / 24;
    canvas.scale(s);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (icon) {
      case FramedIcon.reticle:
        _brackets(canvas, stroke, inset: 2, arm: 4.5);
      case FramedIcon.target:
        _brackets(canvas, stroke, inset: 3, arm: 4);
        canvas.drawCircle(const Offset(12, 12), 2.5, fill);
      case FramedIcon.frame:
        _brackets(canvas, stroke, inset: 3, arm: 4);
        // The shutter: one horizontal bar mid-frame, the moment of capture.
        canvas.drawLine(const Offset(8, 12), const Offset(16, 12), stroke);
      case FramedIcon.compass:
        // A needle, not a full rose — the pulse gives one bearing, once.
        canvas.drawPath(
          Path()
            ..moveTo(12, 4)
            ..lineTo(17, 19)
            ..lineTo(12, 15.5)
            ..lineTo(7, 19)
            ..close(),
          fill,
        );
      case FramedIcon.geofence:
        // The brackets bent into a perimeter: same four arcs, same corners,
        // curved. Dashed, because a boundary you can cross isn't a wall.
        _dashedCircle(canvas, stroke, radius: 8.5);
        canvas.drawCircle(const Offset(12, 12), 2, fill);
      case FramedIcon.warning:
        // The frame blows apart: same four brackets, shoved outward off
        // their corners. The exclamation does the actual communicating —
        // this icon lands on a rule-break with a countdown attached, so it
        // has to be understood before it's admired.
        _brackets(canvas, stroke, inset: 1.5, arm: 3, explode: 1.5);
        canvas.drawLine(const Offset(12, 6.5), const Offset(12, 14), stroke);
        canvas.drawCircle(const Offset(12, 17.5), 1.3, fill);
    }
  }

  /// The motif. [explode] shifts each bracket outward along its own
  /// diagonal, keeping its orientation — a frame pulled apart rather than a
  /// frame drawn wrong.
  void _brackets(
    Canvas canvas,
    Paint p, {
    required double inset,
    required double arm,
    double explode = 0,
  }) {
    final lo = inset, hi = 24 - inset;
    for (final (x, y, sx, sy) in [
      (lo, lo, 1.0, 1.0),
      (hi, lo, -1.0, 1.0),
      (hi, hi, -1.0, -1.0),
      (lo, hi, 1.0, -1.0),
    ]) {
      final ox = x - sx * explode, oy = y - sy * explode;
      canvas.drawPath(
        Path()
          ..moveTo(ox + sx * arm, oy)
          ..lineTo(ox, oy)
          ..lineTo(ox, oy + sy * arm),
        p,
      );
    }
  }

  void _dashedCircle(Canvas canvas, Paint p, {required double radius}) {
    const segments = 8;
    const gap = 0.30; // fraction of each segment left open
    const sweep = (2 * math.pi) / segments;
    final rect = Rect.fromCircle(center: const Offset(12, 12), radius: radius);
    for (var i = 0; i < segments; i++) {
      canvas.drawArc(
        rect,
        i * sweep + sweep * gap / 2,
        sweep * (1 - gap),
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_FramedIconPainter old) =>
      old.icon != icon || old.color != color;
}
