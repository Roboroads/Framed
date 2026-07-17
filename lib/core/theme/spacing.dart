import 'package:flutter/widgets.dart';

/// The spacing scale. Every gap and pad in the app comes from here.
///
/// These aren't new values — they're the ones the codebase already reached
/// for by instinct (16 twenty-five times, 8 twenty times, 24 thirteen). The
/// point of naming them isn't to change any spacing; it's that the next gap
/// someone adds is picked from a set of six rather than invented, so the
/// rhythm holds as screens get rebuilt.
///
/// If a layout seems to need a value that isn't here, it almost always needs
/// one of these instead. Add to the scale only with a reason.
abstract final class Space {
  /// Hairline: between a label and the thing it labels.
  static const xs = 4.0;

  /// Between closely related items in a list or row.
  static const sm = 8.0;

  /// Between a group's members.
  static const md = 12.0;

  /// The default. Between distinct items, and the standard inner padding.
  static const lg = 16.0;

  /// Between sections, and the standard screen edge inset.
  static const xl = 24.0;

  /// Between things that aren't related — the breath around a decision.
  static const xxl = 48.0;
}

/// Vertical gaps, so a `Column` reads as content rather than as content
/// interleaved with `SizedBox` bookkeeping.
abstract final class Gap {
  static const xs = SizedBox(height: Space.xs);
  static const sm = SizedBox(height: Space.sm);
  static const md = SizedBox(height: Space.md);
  static const lg = SizedBox(height: Space.lg);
  static const xl = SizedBox(height: Space.xl);
  static const xxl = SizedBox(height: Space.xxl);
}

/// Horizontal gaps, for `Row`.
abstract final class HGap {
  static const xs = SizedBox(width: Space.xs);
  static const sm = SizedBox(width: Space.sm);
  static const md = SizedBox(width: Space.md);
  static const lg = SizedBox(width: Space.lg);
  static const xl = SizedBox(width: Space.xl);
}

/// Common insets.
abstract final class Insets {
  /// The standard screen gutter.
  static const screen = EdgeInsets.all(Space.xl);

  /// The standard inner padding for a panel or card.
  static const panel = EdgeInsets.all(Space.lg);
}
