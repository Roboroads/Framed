import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/widgets/geofence_map.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../domain/geofence_info.dart';
import '../ingame_state.dart';

/// The soft-punishment target map (#18) — only the target's assassin ever
/// receives target_location, so this panel only ever renders for them.
class TargetLocationPanel extends StatelessWidget {
  const TargetLocationPanel({
    required this.location,
    required this.geofence,
    super.key,
  });

  final IngameTargetLocation location;
  final GeofenceInfo geofence;

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).extension<GameColors>()!.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.ingame.targetLocationTitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: danger),
        ),
        Gap.sm,
        ClipRRect(
          borderRadius: AppTheme.corner,
          child: SizedBox(
            height: 200,
            child: GeofenceMap(
              center: LatLng(geofence.lat, geofence.lng),
              radiusM: geofence.radiusM.toDouble(),
              targetMarker: LatLng(location.lat, location.lng),
            ),
          ),
        ),
      ],
    );
  }
}
