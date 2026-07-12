import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'target.freezed.dart';

/// The player this device's owner must frame — decrypted and ready to
/// render, never the raw ciphertext/path the server sent.
@freezed
sealed class Target with _$Target {
  const factory Target({
    required String playerId,
    required String name,
    required Uint8List selfieBytes,
  }) = _Target;
}
