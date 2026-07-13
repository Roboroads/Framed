import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'judging_frame.freezed.dart';

/// A frame awaiting this player's vote — decrypted and ready to render,
/// never the raw ciphertext/path the server sent.
@freezed
sealed class JudgingFrame with _$JudgingFrame {
  const factory JudgingFrame({
    required String frameId,
    required Uint8List photoBytes,
    required String targetName,
    required Uint8List targetSelfieBytes,
  }) = _JudgingFrame;
}
