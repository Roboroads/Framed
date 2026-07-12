import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// OSM map showing (and letting the host pick) a center point and radius —
/// the geofence for a game. Tap to move the center; [radiusM] is drawn as a
/// live circle overlay, controlled by the caller (e.g. a slider alongside
/// this widget).
///
/// Bare wrapper, reused by the soft-punishment map (issue #18) — this widget
/// only knows about center/radius, nothing game-specific.
class GeofenceMap extends StatelessWidget {
  const GeofenceMap({
    required this.center,
    required this.radiusM,
    required this.onCenterChanged,
    this.interactive = true,
    super.key,
  });

  final LatLng center;
  final double radiusM;
  final ValueChanged<LatLng>? onCenterChanged;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all
              : InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        onTap: interactive && onCenterChanged != null
            ? (_, point) => onCenterChanged!(point)
            : null,
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
          ],
        ),
      ],
    );
  }
}

/// Resolves the device's current position for the map's initial center.
/// Returns [fallback] if the service or permission isn't available —
/// picking a geofence by tapping the map still works either way.
Future<LatLng> currentLocationOrFallback(LatLng fallback) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return fallback;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
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
