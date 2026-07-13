import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../i18n/strings.g.dart';
import '../theme/app_theme.dart';
import 'permission_rationale.dart';

/// OSM map showing the game's geofence: a live view of [center] (always the
/// host's current location — see [currentLocationOrFallback]) and [radiusM],
/// drawn as a circle overlay controlled by the caller (e.g. a slider
/// alongside this widget). Not user-adjustable — the center tracks GPS, it
/// isn't a free-placement picker.
///
/// [targetMarker]/[targetLabel] are the soft-punishment map's addition
/// (#18): the target's exact location, outside the circle by definition —
/// unused (null) by the host-setup picker this was originally built for.
class GeofenceMap extends StatelessWidget {
  const GeofenceMap({
    required this.center,
    required this.radiusM,
    this.targetMarker,
    this.targetLabel,
    super.key,
  });

  final LatLng center;
  final double radiusM;
  final LatLng? targetMarker;
  final String? targetLabel;

  @override
  Widget build(BuildContext context) {
    final target = targetMarker;
    final danger = Theme.of(context).extension<GameColors>()?.danger;
    return FlutterMap(
      options: MapOptions(
        initialCenter: target ?? center,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'me.roboroads.framed',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: center,
              radius: radiusM,
              useRadiusInMeter: true,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              borderColor: Theme.of(context).colorScheme.primary,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              child: Icon(
                Icons.location_pin,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
            ),
            if (target != null)
              Marker(
                point: target,
                width: 140,
                height: 56,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (targetLabel != null)
                      Text(
                        targetLabel!,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: danger),
                      ),
                    Icon(Icons.person_pin_circle, color: danger, size: 32),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Resolves the device's current position for the map's center. Returns
/// [fallback] if the service or permission isn't available.
Future<LatLng> currentLocationOrFallback(
  BuildContext context,
  LatLng fallback,
) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return fallback;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return fallback;
      final proceed = await showPermissionRationale(
        context: context,
        icon: Icons.location_on_outlined,
        explanation: t.permissionRationale.locationExplanation,
      );
      if (!proceed) return fallback;
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return fallback;
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return fallback;
  }
}
