import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/widgets/full_screen_photo_page.dart';

/// A rounded, tappable photo that opens full-screen on tap (#94) — the
/// death screen's frame photo, both judging-overlay photos, and the
/// target card's selfie all shared this exact shape (differing only in
/// corner radius and [BoxFit]). Sizing (aspect ratio, max height) is the
/// caller's concern, wrapped around this widget rather than baked in.
class TappablePhoto extends StatelessWidget {
  const TappablePhoto({
    required this.bytes,
    required this.radius,
    required this.fit,
    super.key,
  });

  final Uint8List bytes;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FullScreenPhotoPage.open(context, bytes),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(bytes, fit: fit),
      ),
    );
  }
}
