import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/crypto/qr_payload.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/motion.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Full-screen QR scan from the Home "Join game" button. Hands a valid
/// payload straight to the join page; anything malformed keeps scanning.
///
/// This is the one screen where the brand mark is not decoration. The app's
/// logo is a viewfinder reticle, and here the user is literally holding a
/// viewfinder up to a thing and waiting for it to lock. The reticle is the
/// scan target, and when the code is read it does what a reticle does: it
/// closes.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _handled = false;
  bool _locked = false;
  int _attempt = 0;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final QrPayload payload;
    try {
      payload = QrPayload.parse(raw);
    } on QrPayloadFormatException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.scan.invalidCode)));
      return;
    }

    _handled = true;
    setState(() => _locked = true);
    // Hold on the lock for a beat before leaving. A scan that works and a
    // scan that hasn't happened yet look identical while you're waving a
    // phone at a code — this is the screen saying "yes, that one", and it's
    // the difference between trusting the app and scanning twice.
    await Future<void>.delayed(Motion.gate(context, Motion.standard));
    if (mounted) context.go('/join', extra: payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Black, not the theme surface: this is a camera screen. The white
      // AppBar text and the error state both assume a dark backdrop, and
      // when the feed fails (errorBuilder) or is still starting there's no
      // feed to provide one — in light mode that left white-on-white.
      backgroundColor: Colors.black,
      // The bar floats over the feed: cropping a camera preview to fit a
      // solid bar costs the user viewfinder, which is the whole screen.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.scan.title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        // titleTextStyle has to be restated, not just foregroundColor: the
        // AppBarTheme's own titleTextStyle carries onSurface and wins over
        // foregroundColor, which left the title dark-on-dark over the camera
        // feed. Same reason as the shadow below — nothing here can assume
        // what's behind it.
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          shadows: const [Shadow(blurRadius: 8)],
        ),
      ),
      body: MobileScanner(
        key: ValueKey(_attempt),
        onDetect: _onDetect,
        overlayBuilder: (context, constraints) => _ScanOverlay(locked: _locked),
        errorBuilder: (context, error) =>
            _ScanError(error: error, onRetry: () => setState(() => _attempt++)),
      ),
    );
  }
}

/// The reticle over the feed, plus the dark everywhere it isn't.
class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: locked ? 1 : 0),
      duration: Motion.gate(context, Motion.quick),
      curve: Motion.enter,
      builder: (context, lock, _) => Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ReticlePainter(lock: lock)),
          Positioned(
            left: 0,
            right: 0,
            bottom: Space.xxl,
            child: Text(
              locked ? t.scan.locked : t.scan.instruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                // The feed behind this is whatever the room looks like, so
                // the text carries its own contrast rather than trusting it.
                shadows: const [Shadow(blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({required this.lock});

  /// 0 = hunting, 1 = locked.
  final double lock;

  @override
  void paint(Canvas canvas, Size size) {
    // A square, because a QR is one, sized to the narrow edge so it works in
    // either orientation and on a fold.
    final side = math.min(size.width, size.height) * 0.68;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      // Closes by a few pixels on lock — the reticle catching, the same beat
      // the wordmark plays on the home screen.
      width: side - lock * 12,
      height: side - lock * 12,
    );

    // Everything outside the target goes dark. Not for style: a QR reader
    // wants the code centred and close, and dimming is how you say that
    // without a sentence.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: AppTheme.corner.topLeft,
            topRight: AppTheme.corner.topRight,
            bottomLeft: AppTheme.corner.bottomLeft,
            bottomRight: AppTheme.corner.bottomRight,
          ),
        ),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    final arm = rect.width * 0.18;
    final paint = Paint()
      ..color = Color.lerp(Colors.white, AppTheme.seed, lock)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + lock
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
  }

  @override
  bool shouldRepaint(_ReticlePainter old) => old.lock != lock;
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? t.camera.permissionDeniedBody
        : t.camera.errorGeneric;
    // On the black camera backdrop, so the copy carries its own light colour
    // rather than the theme's onSurface (dark in light mode).
    return Center(
      child: Padding(
        padding: Insets.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Colors.white,
            ),
            Gap.lg,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            Gap.lg,
            FilledButton(onPressed: onRetry, child: Text(t.camera.retry)),
          ],
        ),
      ),
    );
  }
}
