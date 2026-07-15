import 'package:characters/characters.dart';
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

    // #103: the cap counts grapheme clusters, not UTF-16 code units -- a
    // plain substring cut can land inside a surrogate pair.
    test('caps a pure-emoji name without leaving a lone surrogate', () {
      final long = '😀' * (maxDisplayNameLength + 5);

      final result = sanitizeDisplayName(long);

      expect(result.characters.length, maxDisplayNameLength);
      expect(result, '😀' * maxDisplayNameLength);
    });

    test('an odd code-unit prefix does not shift the cut mid-pair', () {
      final long = 'x${'😀' * (maxDisplayNameLength + 5)}';

      final result = sanitizeDisplayName(long);

      expect(result.characters.length, maxDisplayNameLength);
      expect(result, 'x${'😀' * (maxDisplayNameLength - 1)}');
    });

    test('does not touch an already-clean short name', () {
      expect(sanitizeDisplayName('Alice'), 'Alice');
    });
  });
}
