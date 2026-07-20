import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../core/widgets/pinned_action_bar.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../domain/geofence_info.dart';
import '../../../domain/target.dart';
import '../ingame_state.dart';
import 'compass_panel.dart';
import 'frame_button.dart';
import 'reticle_frame.dart';
import 'tappable_photo.dart';
import 'target_location_panel.dart';

/// The screen a player lives in while hunting: who the target is, which way
/// and how far (when a pulse is live), and the one action — frame them.
///
/// A dossier, not a centred stack. The intel scrolls (a pulse, and for a
/// soft-punished assassin a whole map, can pile up past one screen), and the
/// Frame button is pinned in the thumb zone so the primary action sits at a
/// fixed address no matter how tall the intel above it gets. This is a game
/// played one-handed and walking.
class TargetCard extends StatelessWidget {
  const TargetCard({
    required this.target,
    required this.compass,
    required this.nextPulseAt,
    required this.hasWarning,
    required this.targetLocation,
    required this.geofence,
    required this.frameStatus,
    super.key,
  });

  final Target target;
  final IngameCompass? compass;
  final DateTime? nextPulseAt;
  final bool hasWarning;
  final IngameTargetLocation? targetLocation;
  final GeofenceInfo? geofence;
  final IngameFrameStatus frameStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: Insets.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.ingame.targetCardTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.lg,
                // A focused portrait held in the reticle: the person you're
                // here to frame, in the mark's own sights. Cover at 3:4 (as
                // the death screen frames its photo) so a portrait selfie
                // fills the brackets instead of floating in a letterbox.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ReticleFrame(
                        color: theme.colorScheme.onSurfaceVariant,
                        child: TappablePhoto(
                          bytes: target.selfieBytes,
                          radius: 8,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Gap.lg,
                Text(
                  target.name,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Gap.xl,
                CompassPanel(
                  compass: compass,
                  nextPulseAt: nextPulseAt,
                  hasWarning: hasWarning,
                ),
                if (targetLocation case final location?)
                  if (geofence case final geofence?) ...[
                    Gap.xl,
                    TargetLocationPanel(location: location, geofence: geofence),
                  ],
              ],
            ),
          ),
        ),
        PinnedActionBar(child: FrameButton(status: frameStatus)),
      ],
    );
  }
}
