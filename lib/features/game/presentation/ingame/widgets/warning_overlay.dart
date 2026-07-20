import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_state.dart';
import 'breathe.dart';
import 'countdown_text.dart';

/// The rule-break modal (#12/#13). Full-screen and unmissable per IDEA.md —
/// the back gesture can't dismiss it (see the PopScope on IngamePage), only
/// the server clearing the break can. It says three things in order: something
/// is wrong (the pulsing alarm), what to do about it (the reason, which for a
/// geofence break is literally "go back"), and how long is left (the death
/// clock, the hero of the screen).
class WarningOverlay extends StatelessWidget {
  const WarningOverlay({required this.warning, super.key});

  final IngameWarning warning;

  String _reasonText(String reason) => switch (reason) {
    'geofence' => t.ingame.warningGeofence,
    'stale' => t.ingame.warningStale,
    _ => reason,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = theme.extension<GameColors>()!.danger;

    return Positioned.fill(
      // Solid surface, not translucent: it has to fully occlude the target and
      // compass behind it so a glance lands on the alarm and nothing else.
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: SafeArea(
          // Centred when it fits, scrollable when it doesn't: the death clock
          // is the last child and the one number that must never be clipped,
          // so at large text scale on a small screen this scrolls rather than
          // pushing it past the bottom edge.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: Insets.screen,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 168,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Breathe(
                                min: 0.15,
                                max: 0.55,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        danger.withValues(alpha: 0.5),
                                        danger.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              FramedIcons(
                                FramedIcon.warning,
                                size: 72,
                                color: danger,
                              ),
                            ],
                          ),
                        ),
                        Gap.xl,
                        for (final reason in warning.reasons)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Space.md),
                            child: Text(
                              _reasonText(reason),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        Gap.lg,
                        CountdownText(
                          deadline: warning.hardDeadline,
                          builder: (context, time) => Text(
                            t.ingame.warningDeadline(time: time),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The proactive edge nudge (#61): still inside the geofence, but close to
/// leaving it. Deliberately lightweight compared to [WarningOverlay] — a
/// dismissable-by-nature banner, not a blocking full-screen modal, since
/// nothing is actually being punished yet.
class ProximityBanner extends StatelessWidget {
  const ProximityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final warningColor = Theme.of(context).extension<GameColors>()!.warning;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(Space.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          decoration: BoxDecoration(
            color: warningColor.withValues(alpha: 0.15),
            borderRadius: AppTheme.corner,
            border: Border.all(color: warningColor),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_circle_left_outlined, color: warningColor),
              HGap.md,
              Expanded(
                child: Text(
                  t.ingame.nearGeofenceEdge,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: warningColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
