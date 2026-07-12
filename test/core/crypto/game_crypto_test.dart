import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';

void main() {
  group('GameCrypto', () {
    test('round-trips a string', () async {
      final crypto = await GameCrypto.generate();
      final blob = await crypto.encryptString('hello Framed');

      expect(await crypto.decryptString(blob), 'hello Framed');
    });

    test('round-trips a multi-megabyte byte list', () async {
      final crypto = await GameCrypto.generate();
      final bytes = Uint8List(3 * 1024 * 1024);
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = i % 256;
      }

      final blob = await crypto.encrypt(bytes);
      expect(await crypto.decrypt(blob), equals(bytes));
    });

    test(
      'two encryptions of the same plaintext differ (nonce freshness)',
      () async {
        final crypto = await GameCrypto.generate();

        final a = await crypto.encryptString('same message');
        final b = await crypto.encryptString('same message');

        expect(a, isNot(equals(b)));
      },
    );

    test('flipping one ciphertext byte makes decrypt throw', () async {
      final crypto = await GameCrypto.generate();
      final blob = await crypto.encryptString('tamper me');

      final bytes = base64Decode(blob);
      // Flip a bit inside the ciphertext region (after the 12-byte nonce).
      bytes[12] ^= 0x01;
      final tampered = base64Encode(bytes);

      expect(
        () => crypto.decryptString(tampered),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('the joining side reconstructs the same key from its bytes', () async {
      final host = await GameCrypto.generate();
      final keyBytes = await host.keyBytes;
      final joiner = await GameCrypto.fromKeyBytes(keyBytes);

      final blob = await host.encryptString('shared secret');
      expect(await joiner.decryptString(blob), 'shared secret');
    });

    test('nameHmac normalizes case and whitespace', () async {
      final crypto = await GameCrypto.generate();

      expect(await crypto.nameHmac('  Bob '), await crypto.nameHmac('bob'));
    });

    test('nameHmac differs under a different key', () async {
      final a = await GameCrypto.generate();
      final b = await GameCrypto.generate();

      expect(await a.nameHmac('bob'), isNot(equals(await b.nameHmac('bob'))));
    });
  });
}
