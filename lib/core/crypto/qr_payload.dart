import 'dart:convert';
import 'dart:typed_data';

/// Thrown when a scanned QR string is not a valid Framed join payload.
///
/// This string comes from someone else's screen — parsing must never crash.
class QrPayloadFormatException implements Exception {
  const QrPayloadFormatException(this.reason);

  final String reason;

  @override
  String toString() => 'QrPayloadFormatException: $reason';
}

/// `framed://join?v=1&t={join_token}&k={base64url game key}`
class QrPayload {
  const QrPayload({required this.joinToken, required this.keyBytes});

  static const _version = '1';

  final String joinToken;
  final Uint8List keyBytes;

  String encode() {
    final key = base64Url.encode(keyBytes).replaceAll('=', '');
    return 'framed://join?v=$_version&t=$joinToken&k=$key';
  }

  static QrPayload parse(String raw) {
    final Uri uri;
    try {
      uri = Uri.parse(raw);
    } on FormatException {
      throw const QrPayloadFormatException('not a valid URI');
    }
    if (uri.scheme != 'framed' || uri.host != 'join') {
      throw const QrPayloadFormatException('not a framed join link');
    }

    final version = uri.queryParameters['v'];
    if (version != _version) {
      throw QrPayloadFormatException('unsupported version: $version');
    }

    final token = uri.queryParameters['t'];
    final key = uri.queryParameters['k'];
    if (token == null || token.isEmpty || key == null || key.isEmpty) {
      throw const QrPayloadFormatException('missing token or key');
    }

    final Uint8List keyBytes;
    try {
      keyBytes = base64Url.decode(base64Url.normalize(key));
    } on FormatException {
      throw const QrPayloadFormatException('key is not valid base64url');
    }

    return QrPayload(joinToken: token, keyBytes: keyBytes);
  }
}
