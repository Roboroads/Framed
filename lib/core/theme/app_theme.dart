import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'motion.dart';
import 'spacing.dart';

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

  /// Crimson, lifted just far enough to survive a near-black surface.
  ///
  /// The seed can't be used directly in dark mode: `#B3202E` against the
  /// dark surface (`#1A1111`) measures 2.79:1, under the 3:1 WCAG floor for
  /// a UI component, so the button's own edge would be the failing part. At
  /// `#CC2936` the fill clears the surface at 3.48:1 and still carries white
  /// at 5.33:1. Going brighter buys edge contrast and spends label contrast
  /// — `#E0313E`, which the app icon uses, drops white to 4.49:1 and fails
  /// the other way. This is the window where both hold.
  ///
  /// Numbers from test/theme/contrast_test.dart, which fails if any of this
  /// stops being true.
  static const _crimsonOnDark = Color(0xFFCC2936);

  static ThemeData _build(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    // fromSeed flattens the seed into a tonal palette, which turns "frame
    // crimson" into a pale pink in dark mode (#FFB3B1) and a muted brick in
    // light (#904A49). Neither is the brand, and a pastel-pink slab under a
    // viewfinder undercuts the whole identity — so primary is stated rather
    // than derived. Every other role still comes from the palette.
    final scheme = brightness == Brightness.dark
        ? base.copyWith(primary: _crimsonOnDark, onPrimary: Colors.white)
        : base.copyWith(primary: seed, onPrimary: Colors.white);
    final text = _textTheme();
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: _voice,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FocusPageTransitionsBuilder(),
          // iOS is left alone deliberately. Its back-swipe and its parallax
          // slide are the same gesture — replacing the animation would leave
          // the swipe dragging a fade, which feels broken rather than
          // designed.
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      filledButtonTheme: FilledButtonThemeData(style: _button(scheme, text)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _button(scheme, text).copyWith(
          foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.12),
              );
            }
            // Thickens on contact instead of filling: the outline *is* the
            // control, so the frame reacting reads truer than a wash of
            // colour appearing behind the label.
            final active =
                states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused);
            return BorderSide(
              color: active ? scheme.primary : scheme.outline,
              width: active ? 2 : 1,
            );
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _button(scheme, text).copyWith(
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          // A text button is a link, not a slab — it shouldn't hold a
          // button's worth of vertical space.
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : scheme.onSurface,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        margin: EdgeInsets.zero,
        // Outlined, not raised. A shadow implies a card floating above the
        // page; these are panels cut into it, like readings on an
        // instrument.
        shape: RoundedRectangleBorder(
          borderRadius: corner,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        border: OutlineInputBorder(
          borderRadius: corner,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: corner,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: corner,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: corner,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: corner,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: text.bodyMedium,
        // Full alpha, not 70%: M3 specifies onSurfaceVariant to clear 4.5:1
        // against a surface, and fading it drops the hint under this
        // project's AA floor. A hint the player can't read outdoors in
        // daylight isn't a subtle hint, it's a missing one.
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: corner,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: corner),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        // Material's default tints the bar as content scrolls under it,
        // which on a dark-first UI reads as the bar lighting up for no
        // reason. The screens here are short; the bar is a place to leave
        // from, not a surface.
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      chipTheme: ChipThemeData(
        // The outline lives in `side`, not in `shape`. ChipThemeData.side
        // overrides whatever border `shape` carries, so declaring it in both
        // silently drops the one in shape.
        shape: RoundedRectangleBorder(borderRadius: corner),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelMedium,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: corner),
          ),
        ),
      ),
      extensions: [
        brightness == Brightness.dark ? GameColors.dark : GameColors.light,
      ],
    );
  }

  /// A filled button carrying one of the semantic [GameColors] instead of the
  /// brand primary — the judging verdict buttons, and anything else where the
  /// colour *is* the meaning.
  ///
  /// This exists so those call sites stop hand-rolling `styleFrom`. A
  /// component theme can't cover them (a theme can't know which button is the
  /// destructive one), but they can still resolve from one place.
  ///
  /// The foreground is derived rather than assumed. [GameColors] deliberately
  /// holds different values per brightness — `danger` is a light coral in
  /// dark mode and a deep red in light mode — so a fixed `onPrimary` would
  /// have been legible against exactly one of them.
  static ButtonStyle semanticFilled(Color background) {
    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor:
          ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
  }

  /// The corner. Public: feature code that draws its own container needs
  /// the same radius, and a private one just guarantees stray literals.
  ///
  /// Material 3 ships fully-rounded buttons, which is the loudest remaining
  /// "this is a stock template" signal after the fonts were fixed. The mark
  /// is drawn entirely with butt caps and mitre joins — there is not one
  /// round corner in the reticle — so pills sitting under it contradict it.
  /// 4 is nearly square without being harsh: it reads as machined, not as
  /// friendly, which is what a viewfinder should read as.
  static const corner = BorderRadius.all(Radius.circular(4));

  /// The shared skeleton every text-bearing button hangs off, so a filled and
  /// an outlined button are the same object wearing different clothes rather
  /// than two things that happen to look alike.
  static ButtonStyle _button(ColorScheme scheme, TextTheme text) {
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      // Comfortably past the 48dp accessibility floor. This game is played
      // one-handed, outdoors, walking, sometimes in a hurry.
      //
      // Size(0, 52), never Size.fromHeight(52) — that helper sets *width* to
      // infinity, which would force every button in the app to fill its
      // parent and turn each centred "Try again" into a full-width slab.
      // Buttons that should stretch are stretched by their own layout.
      minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.md),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: corner),
      ),
      elevation: const WidgetStatePropertyAll(0),
      // No overlayColor here on purpose. Material derives it from each
      // button's own foreground, which is the only thing that works across
      // variants: a filled button sits on `primary` and an outlined one on
      // `surface`, so any single colour hard-coded here is invisible on one
      // of them. States still resolve without a screen rebuilding itself —
      // just from the framework's resolver rather than ours.
      animationDuration: Motion.quick,
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
