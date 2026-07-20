import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../domain/geofence_info.dart';
import '../../../domain/target.dart';
import '../ingame_state.dart';
import 'compass_panel.dart';
import 'frame_button.dart';
import 'tappable_photo.dart';
import 'target_location_panel.dart';

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
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.ingame.targetCardTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Gap.lg,
          // BoxFit.cover at a fixed height cropped portrait selfies down to
          // a near-square sliver — contain (still capped) shows the whole
          // photo instead.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: TappablePhoto(
              bytes: target.selfieBytes,
              radius: 16,
              fit: BoxFit.contain,
            ),
          ),
          Gap.lg,
          Text(
            target.name,
            style: Theme.of(context).textTheme.headlineSmall,
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
          Gap.xl,
          FrameButton(status: frameStatus),
        ],
      ),
    );
  }
}
