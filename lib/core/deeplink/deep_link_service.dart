import 'package:app_links/app_links.dart';

import '../crypto/qr_payload.dart';

/// Listens for `framed://join` deep links (Android intent-filter in
/// AndroidManifest.xml) — the same payload format as the lobby QR code
/// (core/crypto/qr_payload.dart), so tapping a shared link lands on the
/// exact same join flow as scanning it.
class DeepLinkService {
  DeepLinkService(this._onJoinLink);

  final void Function(QrPayload payload) _onJoinLink;
  final _appLinks = AppLinks();

  Future<void> start() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handle(initial);
    _appLinks.uriLinkStream.listen(_handle);
  }

  void _handle(Uri uri) {
    try {
      _onJoinLink(QrPayload.parse(uri.toString()));
    } on QrPayloadFormatException {
      // Not a join link, or malformed — ignore, same tolerance as the QR
      // scanner (features/lobby/presentation/scan/scan_page.dart).
    }
  }
}
