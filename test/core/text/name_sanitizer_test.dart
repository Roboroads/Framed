import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/text/name_sanitizer.dart';

void main() {
  group('sanitizeDisplayName', () {
    test('trims surrounding whitespace', () {
      expect(sanitizeDisplayName('  Robooo  '), 'Robooo');
    });

    test('strips zero-width and bidi control characters', () {
      final zwsp = String.fromCharCode(0x200B);
      final rlo = String.fromCharCode(0x202E);

      expect(sanitizeDisplayName('Rob${zwsp}ooo'), 'Robooo');
      expect(sanitizeDisplayName('Bob$rlo evil'), 'Bob evil');
    });

    test('applies NFKC normalization (fullwidth -> normal width)', () {
      expect(sanitizeDisplayName('ＡＢＣ'), 'ABC');
    });

    test('caps length at maxDisplayNameLength', () {
      final long = 'x' * (maxDisplayNameLength + 20);

      final result = sanitizeDisplayName(long);

      expect(result.length, maxDisplayNameLength);
    });

    test('does not touch an already-clean short name', () {
      expect(sanitizeDisplayName('Alice'), 'Alice');
    });
  });
}
