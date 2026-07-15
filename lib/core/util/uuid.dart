import 'dart:math';

import 'hex.dart';

/// A random RFC 4122 version-4 UUID.
///
/// ponytail: 16 random bytes and two bit twiddles don't need a package.
String generateUuidV4() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10

  String slice(int start, int end) => hex(bytes.sublist(start, end));

  return '${slice(0, 4)}-${slice(4, 6)}-${slice(6, 8)}-${slice(8, 10)}-'
      '${slice(10, 16)}';
}
