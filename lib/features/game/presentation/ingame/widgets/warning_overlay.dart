import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_state.dart';
import 'countdown_text.dart';

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
    final danger = Theme.of(context).extension<GameColors>()!.danger;

    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FramedIcons(FramedIcon.warning, size: 48, color: danger),
                Gap.lg,
                for (final reason in warning.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.md),
                    child: Text(
                      _reasonText(reason),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                Gap.lg,
                CountdownText(
                  deadline: warning.hardDeadline,
                  builder: (context, time) => Text(
                    t.ingame.warningDeadline(time: time),
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: danger),
                  ),
                ),
              ],
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
