import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The one class every encrypted byte in the game flows through.
///
/// Scheme (see IDEA.md "End-to-end encryption"): one AES-256-GCM key per
/// game, generated on the host's device and distributed only via QR. Names,
/// selfies, frame photos, and dead-chat all use the same encrypt/decrypt
/// shape. Locations are never encrypted — the server needs them for
/// authority.
class GameCrypto {
  GameCrypto._(this._secretKey);

  static final _algorithm = AesGcm.with256bits();
  static final _hmac = Hmac.sha256();

  final SecretKey _secretKey;

  /// A fresh key for a newly hosted game.
  static Future<GameCrypto> generate() async {
    return GameCrypto._(await _algorithm.newSecretKey());
  }

  /// Reconstructs the key on the joining side from QR bytes.
  static Future<GameCrypto> fromKeyBytes(List<int> keyBytes) async {
    return GameCrypto._(await _algorithm.newSecretKeyFromBytes(keyBytes));
  }

  Future<Uint8List> get keyBytes async =>
      Uint8List.fromList(await _secretKey.extractBytes());

  /// `base64(nonce(12) ‖ ciphertext ‖ tag(16))`, fresh nonce every call.
  Future<String> encrypt(List<int> plaintext) async {
    final box = await _algorithm.encrypt(plaintext, secretKey: _secretKey);
    return base64Encode(box.concatenation());
  }

  Future<String> encryptString(String plaintext) =>
      encrypt(utf8.encode(plaintext));

  /// Reverses [encrypt]. Throws [SecretBoxAuthenticationError] on tampered
  /// or corrupt input.
  Future<Uint8List> decrypt(String blob) async {
    final box = SecretBox.fromConcatenation(
      base64Decode(blob),
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final plain = await _algorithm.decrypt(box, secretKey: _secretKey);
    return Uint8List.fromList(plain);
  }

  Future<String> decryptString(String blob) async =>
      utf8.decode(await decrypt(blob));

  /// hex HMAC-SHA256 of the trimmed, lowercased name — the server's basis
  /// for rejecting duplicate names it cannot read (unique on
  /// (game_id, name_hmac)).
  Future<String> nameHmac(String name) async {
    final normalized = utf8.encode(name.trim().toLowerCase());
    final mac = await _hmac.calculateMac(normalized, secretKey: _secretKey);
    return mac.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
