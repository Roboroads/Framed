import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Full-screen pinch-to-zoom/pan viewer for an already-decrypted photo
/// (#55) — every tappable photo in the app opens this. [photoBytes] stays
/// in memory only: [PhotoView] decodes straight from the bytes via
/// [MemoryImage], nothing touches disk or a new codec path that could
/// persist it.
class FullScreenPhotoPage extends StatelessWidget {
  const FullScreenPhotoPage({required this.photoBytes, super.key});

  final Uint8List photoBytes;

  /// A plain push, not a go_router route — same reasoning as the other
  /// raw-bytes screens app_router.dart documents (non-serializable,
  /// non-bookmarkable; a plain push still layers fine on GoRouter's
  /// Navigator).
  static void open(BuildContext context, Uint8List photoBytes) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullScreenPhotoPage(photoBytes: photoBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: MemoryImage(photoBytes),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
      ),
    );
  }
}
