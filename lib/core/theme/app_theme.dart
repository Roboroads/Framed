import 'package:flutter/material.dart';

/// Framed design system.
///
/// Dark-first: the game is played outside, often at dusk, phone in hand —
/// a dark UI kills glare and battery. A light theme exists for the few
/// indoor screens (lobby, stats) and follows system preference.
///
/// Accessibility: scheme roles come from Material 3 tonal palettes
/// (contrast guaranteed by the M3 spec). The semantic game colors in
/// [GameColors] are hand-picked to hit WCAG AA (>= 4.5:1) against the dark
/// surface and are never the only signal — every state also has an icon or
/// label (color-blind safe).
abstract final class AppTheme {
  /// Brand seed: "frame" crimson — the color of a confirmed kill.
  static const seed = Color(0xFFB3202E);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      extensions: [
        brightness == Brightness.dark ? GameColors.dark : GameColors.light,
      ],
    );
  }
}

/// Semantic game-state colors. Use these, never raw hex, in feature code:
/// `Theme.of(context).extension<GameColors>()!`.
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.alive,
    required this.danger,
    required this.warning,
    required this.dead,
    required this.compass,
  });

  /// You / a player is alive and in good standing.
  final Color alive;

  /// Kill, frame verdict "yes", hard punishment.
  final Color danger;

  /// Rule-break warnings, soft punishment, cooldowns.
  final Color warning;

  /// Dead players, expired pulses, disabled intel.
  final Color dead;

  /// Compass pulse arrow + distance.
  final Color compass;

  /// >= 4.5:1 (WCAG AA) against dark surfaces.
  static const dark = GameColors(
    alive: Color(0xFF4CC38A),
    danger: Color(0xFFFF6369),
    warning: Color(0xFFFFC53D),
    dead: Color(0xFF9BA1A6),
    compass: Color(0xFF52C7EA),
  );

  /// >= 4.5:1 (WCAG AA) against light surfaces.
  static const light = GameColors(
    alive: Color(0xFF18794E),
    danger: Color(0xFFC62A2F),
    warning: Color(0xFF946800),
    dead: Color(0xFF5F6569),
    compass: Color(0xFF00749E),
  );

  @override
  GameColors copyWith({
    Color? alive,
    Color? danger,
    Color? warning,
    Color? dead,
    Color? compass,
  }) {
    return GameColors(
      alive: alive ?? this.alive,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      dead: dead ?? this.dead,
      compass: compass ?? this.compass,
    );
  }

  @override
  GameColors lerp(GameColors? other, double t) {
    if (other == null) return this;
    return GameColors(
      alive: Color.lerp(alive, other.alive, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      dead: Color.lerp(dead, other.dead, t)!,
      compass: Color.lerp(compass, other.compass, t)!,
    );
  }
}
