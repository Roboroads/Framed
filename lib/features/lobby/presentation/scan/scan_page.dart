import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/crypto/qr_payload.dart';
import '../../../../i18n/strings.g.dart';
import '../join/join_page.dart';

/// Full-screen QR scan from the Home "Join game" button. Hands a valid
/// payload straight to the join page; anything malformed keeps scanning.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _handled = false;
  int _attempt = 0;

  void _onDetect(BarcodeCapture capture) {
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => JoinPage(
          joinToken: payload.joinToken,
          gameKeyBytes: payload.keyBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.scan.title)),
      body: MobileScanner(
        key: ValueKey(_attempt),
        onDetect: _onDetect,
        errorBuilder: (context, error) =>
            _ScanError(error: error, onRetry: () => setState(() => _attempt++)),
      ),
    );
  }
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(t.camera.retry)),
          ],
        ),
      ),
    );
  }
}
