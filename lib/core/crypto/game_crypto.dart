import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../text/name_sanitizer.dart';

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

  /// Raw `nonce(12) ‖ ciphertext ‖ tag(16)`, fresh nonce every call — what
  /// Storage blobs (selfies, frame photos) upload directly, no text
  /// encoding wasted on binary content.
  Future<Uint8List> encryptBytes(List<int> plaintext) async {
    final box = await _algorithm.encrypt(plaintext, secretKey: _secretKey);
    return box.concatenation();
  }

  /// `base64(nonce(12) ‖ ciphertext ‖ tag(16))` — for text columns (names,
  /// chat).
  Future<String> encrypt(List<int> plaintext) async =>
      base64Encode(await encryptBytes(plaintext));

  Future<String> encryptString(String plaintext) =>
      encrypt(utf8.encode(plaintext));

  /// Reverses [encryptBytes]. Throws [SecretBoxAuthenticationError] on
  /// tampered or corrupt input.
  Future<Uint8List> decryptBytes(List<int> blob) async {
    final box = SecretBox.fromConcatenation(
      blob,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final plain = await _algorithm.decrypt(box, secretKey: _secretKey);
    return Uint8List.fromList(plain);
  }

  /// Reverses [encrypt].
  Future<Uint8List> decrypt(String blob) => decryptBytes(base64Decode(blob));

  Future<String> decryptString(String blob) async =>
      utf8.decode(await decrypt(blob));

  /// hex HMAC-SHA256 of the sanitized, lowercased name — the server's
  /// basis for rejecting duplicate names it cannot read (unique on
  /// (game_id, name_hmac)). [sanitizeDisplayName] (#79) is called here too
  /// as a backstop, not just at the pre-join call sites — this is the
  /// actual dedup enforcement point, so it shouldn't depend on every
  /// caller remembering to sanitize first.
  Future<String> nameHmac(String name) async {
    final normalized = utf8.encode(sanitizeDisplayName(name).toLowerCase());
    final mac = await _hmac.calculateMac(normalized, secretKey: _secretKey);
    return mac.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
