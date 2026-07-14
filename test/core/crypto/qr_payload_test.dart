import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/qr_payload.dart';

void main() {
  group('QrPayload', () {
    test('round-trips through encode/parse', () {
      final original = QrPayload(
        joinToken: 'abc123XYZ',
        keyBytes: Uint8List.fromList(List.generate(32, (i) => i)),
      );

      final parsed = QrPayload.parse(original.encode());

      expect(parsed.joinToken, original.joinToken);
      expect(parsed.keyBytes, equals(original.keyBytes));
    });

    test('encodes an https link with the key in the fragment', () {
      final payload = QrPayload(
        joinToken: 'abc123XYZ',
        keyBytes: Uint8List.fromList(List.generate(32, (i) => i)),
      );

      final encoded = payload.encode();

      expect(
        encoded,
        startsWith('https://getframed.fun/join?v=1&t=abc123XYZ#k='),
      );
    });

    test('parses the router rewrite\'s bare path form', () {
      // app_router.dart's _redirectJoinLink rewrites the incoming
      // https://getframed.fun/join?... link to a relative /join?... path
      // before this ever gets parsed again — no scheme or host survives
      // that rewrite, only path + query + fragment.
      final parsed = QrPayload.parse('/join?v=1&t=abc#k=AQIDBA');

      expect(parsed.joinToken, 'abc');
    });

    test('rejects an unsupported version', () {
      expect(
        () => QrPayload.parse('https://getframed.fun/join?v=2&t=abc#k=AQIDBA'),
        throwsA(isA<QrPayloadFormatException>()),
      );
    });

    test('rejects garbage input instead of crashing', () {
      for (final garbage in [
        'not a uri at all: {{{',
        'https://example.com/settings?v=1&t=abc#k=AQIDBA',
        'https://getframed.fun/join?v=1#k=AQIDBA',
        'https://getframed.fun/join?v=1&t=abc',
        'https://getframed.fun/join?v=1&t=abc&k=AQIDBA', // key in the query, not the fragment
        'https://getframed.fun/join?v=1&t=abc#k=not-valid-base64!!',
        '',
      ]) {
        expect(
          () => QrPayload.parse(garbage),
          throwsA(isA<QrPayloadFormatException>()),
          reason: 'expected "$garbage" to be rejected',
        );
      }
    });
  });
}
