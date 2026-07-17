import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../theme/app_theme.dart';

/// The wordmark: the word FRAMED inside a viewfinder's corner brackets.
///
/// The joke is the whole identity — the word is the subject, and it's being
/// framed. On first build the brackets travel inward and settle, the way a
/// camera's autofocus locks onto what you pointed it at. It plays once, on
/// the one screen that opens the app; nothing else in the UI moves like this.
class FramedWordmark extends StatelessWidget {
  const FramedWordmark({super.key, this.fontSize = 40});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A locked-focus animation that a user can't perceive as focus locking
    // is just a moving logo, so it's dropped rather than shortened when the
    // platform asks for less motion.
    final still = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: t.app.title,
      // The brackets and the letters are one image, not a word with
      // decoration — a screen reader should hear the brand once.
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        duration: still ? Duration.zero : const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        // Named `value`, not `t` — slang's translations are also `t`.
        builder: (context, value, child) => CustomPaint(
          painter: _ReticlePainter(progress: value, color: scheme.onSurface),
          child: child,
        ),
        child: Padding(
          // Room for the brackets to live outside the letters.
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 0.9,
            vertical: fontSize * 0.7,
          ),
          child: Text(
            t.app.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTheme.wordmark(
              fontSize,
            ).copyWith(color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({required this.progress, required this.color});

  /// 0 = brackets wide open and invisible, 1 = locked.
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Overshoot outward at progress 0, then converge onto the text box.
    final travel = (1 - progress) * size.height * 0.55;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).inflate(travel);
    final arm = size.height * 0.34;
    final weight = size.height * 0.055;

    final paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = weight
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

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

    // No focus lamp, no accent dot. Crimson means one thing in this brand —
    // the subject inside the frame, as in the app icon — and there's no
    // subject here but the word itself. A dot parked on an arm's open end
    // said nothing and read as dust.
  }

  @override
  bool shouldRepaint(_ReticlePainter old) =>
      old.progress != progress || old.color != color;
}
