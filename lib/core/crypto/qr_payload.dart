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

/// `https://getframed.fun/join?v=1&t={join_token}#k={base64url game key}`
/// (#66 — an Android App Link / iOS Universal Link, replacing the old
/// `framed://join` custom scheme so the link is tappable when shared into
/// a chat app, not just scannable as a QR code).
///
/// The key rides in the URL *fragment*, deliberately not the query string:
/// a fragment is never sent in the HTTP request (browsers/OSes strip it
/// before the request leaves the device), so it reaches neither
/// getframed.fun's own request logs nor a chat app's link-preview bot
/// (WhatsApp, Signal, Slack, iMessage all fetch shared URLs server-side to
/// build a preview card). That matches the project's one hard rule for
/// this key: it never touches a server, this app's own or anyone else's.
/// `v`/`t` don't need that protection — `v` is just a version tag and `t`
/// is a single-use token the server already treats as low-sensitivity
/// (consumed once via `join_game`, invalid once the game starts).
class QrPayload {
  const QrPayload({required this.joinToken, required this.keyBytes});

  static const _version = '1';
  static const _host = 'getframed.fun';

  final String joinToken;
  final Uint8List keyBytes;

  String encode() {
    final key = base64Url.encode(keyBytes).replaceAll('=', '');
    return 'https://$_host/join?v=$_version&t=$joinToken#k=$key';
  }

  /// Scheme and host are deliberately not checked here: by the time a live
  /// deep link reaches this (rather than a raw QR scan), app_router.dart's
  /// `_redirectJoinLink` has already gated on them and rewritten the URI
  /// to a bare `/join?...#...` path, which has neither. [path] is the one
  /// shape check that still applies to both callers.
  static QrPayload parse(String raw) {
    final Uri uri;
    try {
      uri = Uri.parse(raw);
    } on FormatException {
      throw const QrPayloadFormatException('not a valid URI');
    }
    if (uri.path != '/join') {
      throw const QrPayloadFormatException('not a framed join link');
    }

    final version = uri.queryParameters['v'];
    if (version != _version) {
      throw QrPayloadFormatException('unsupported version: $version');
    }

    final token = uri.queryParameters['t'];
    final key = Uri.splitQueryString(uri.fragment)['k'];
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
