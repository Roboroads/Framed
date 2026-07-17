import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/theme/app_theme.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The design system claims WCAG AA in its own doc comment. These check it,
/// because the claim was wrong before anyone measured: `fromSeed` had quietly
/// turned the brand crimson into a pale pink, and the seed itself can't be
/// dropped into dark mode without failing the non-text floor.
void main() {
  group('primary is really crimson', () {
    test('dark primary is not the pink fromSeed generates', () {
      final primary = AppTheme.dark.colorScheme.primary;
      // The tonal palette's value. If this ever comes back, the copyWith
      // was lost.
      expect(primary, isNot(const Color(0xFFFFB3B1)));
      // Red channel dominant, and not washed out into pink.
      expect(primary.r, greaterThan(0.6));
      expect(primary.g, lessThan(0.4));
      expect(primary.b, lessThan(0.4));
    });

    test('light primary is the brand seed itself', () {
      expect(AppTheme.light.colorScheme.primary, AppTheme.seed);
    });
  });

  group('contrast', () {
    for (final (name, theme) in [
      ('dark', AppTheme.dark),
      ('light', AppTheme.light),
    ]) {
      test('$name: a label on a filled button clears AA (4.5:1)', () {
        final s = theme.colorScheme;
        expect(_contrast(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5));
      });

      // WCAG 1.4.11: a control has to be distinguishable from what's behind
      // it, not just legible once you've found it.
      test('$name: a filled button clears its surface (3:1)', () {
        final s = theme.colorScheme;
        expect(_contrast(s.primary, s.surface), greaterThanOrEqualTo(3.0));
      });

      test('$name: every GameColors role clears AA against the surface', () {
        final game = theme.extension<GameColors>()!;
        final surface = theme.colorScheme.surface;
        for (final (role, color) in [
          ('alive', game.alive),
          ('danger', game.danger),
          ('warning', game.warning),
          ('dead', game.dead),
          ('compass', game.compass),
        ]) {
          expect(
            _contrast(color, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$role on $name surface',
          );
        }
      });
    }
  });
}
