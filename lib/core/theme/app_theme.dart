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

  /// The brand surface behind the mark: app icon, launch screen, wordmark.
  ///
  /// Deliberately not a [ColorScheme] role — it's the one color that has to
  /// hold still across the OS launch window and the Flutter UI, in light
  /// mode and dark alike. Mirrored by hand in
  /// `android/app/src/main/res/values/colors.xml` and
  /// `ios/Runner/Base.lproj/LaunchScreen.storyboard`, neither of which can
  /// read a Dart value.
  static const charcoal = Color(0xFF14100F);

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
      fontFamily: _voice,
      textTheme: _textTheme(),
      extensions: [
        brightness == Brightness.dark ? GameColors.dark : GameColors.light,
      ],
    );
  }

  /// Archivo: an engineered, signage-like grotesk. Carries everything the
  /// app *says*.
  static const _voice = 'Archivo';

  /// IBM Plex Mono: carries everything the app *measures*.
  static const _data = 'IBMPlexMono';

  /// Archivo is a variable font, so weight is an axis rather than a
  /// separate file. [fontWeight] alone doesn't move that axis — the
  /// matching [FontVariation] has to be set too, or every weight renders
  /// as Regular.
  static TextStyle _v(double wght, {double? size, double? ls, double? h}) {
    return TextStyle(
      fontFamily: _voice,
      fontWeight: FontWeight.values[(wght ~/ 100) - 1],
      fontVariations: [FontVariation('wght', wght)],
      fontSize: size,
      letterSpacing: ls,
      height: h,
    );
  }

  /// The `display` roles are reserved for numbers, not for big prose: every
  /// one of them in this app is a countdown or a distance (the dispersal
  /// clock, a rule-break's hard deadline). They're set in mono with tabular
  /// figures so a ticking clock doesn't jitter its own layout as the digits
  /// change width. Prose starts at `headline`.
  static TextTheme _textTheme() {
    const tabular = TextStyle(
      fontFamily: _data,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return TextTheme(
      displayLarge: tabular.copyWith(fontSize: 56, fontWeight: FontWeight.w500),
      displayMedium: tabular.copyWith(
        fontSize: 44,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: tabular.copyWith(fontSize: 30, fontWeight: FontWeight.w500),

      headlineLarge: _v(700, size: 32, ls: -0.6, h: 1.15),
      headlineMedium: _v(700, size: 26, ls: -0.4, h: 1.2),
      headlineSmall: _v(600, size: 22, ls: -0.3, h: 1.25),

      titleLarge: _v(600, size: 20, ls: -0.2),
      titleMedium: _v(600, size: 16),
      titleSmall: _v(600, size: 14),

      bodyLarge: _v(400, size: 16, h: 1.5),
      bodyMedium: _v(400, size: 14, h: 1.5),
      bodySmall: _v(400, size: 12, h: 1.45),

      // Positive tracking on labels: buttons and eyebrows are signage, and
      // Archivo's tight default fit reads cramped at small sizes.
      labelLarge: _v(600, size: 14, ls: 0.5),
      labelMedium: _v(600, size: 12, ls: 0.5),
      labelSmall: _v(600, size: 11, ls: 0.8),
    );
  }

  /// The wordmark's one typographic move: Archivo's width axis pushed wide,
  /// which no amount of `letterSpacing` imitates — the letterforms
  /// themselves stretch, so it reads as drawn rather than tracked-out.
  static TextStyle wordmark(double size) => TextStyle(
    fontFamily: _voice,
    fontSize: size,
    fontWeight: FontWeight.w800,
    fontVariations: const [
      FontVariation('wght', 800),
      FontVariation('wdth', 125),
    ],
    letterSpacing: size * 0.06,
    height: 1,
  );
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
