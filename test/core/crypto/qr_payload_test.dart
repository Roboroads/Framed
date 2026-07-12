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

    test('rejects an unsupported version', () {
      expect(
        () => QrPayload.parse('framed://join?v=2&t=abc&k=AQIDBA'),
        throwsA(isA<QrPayloadFormatException>()),
      );
    });

    test('rejects garbage input instead of crashing', () {
      for (final garbage in [
        'not a uri at all: {{{',
        'https://example.com/join?v=1&t=abc&k=AQIDBA',
        'framed://join?v=1&t=abc',
        'framed://join?v=1&k=AQIDBA',
        'framed://join?v=1&t=abc&k=not-valid-base64!!',
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
