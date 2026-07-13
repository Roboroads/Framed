import 'dart:math' as math;

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
/// isn't a free-placement picker (#43); [interactive] only ever enables
/// looking around (pan/zoom), never repositioning (#60).
///
/// When there's no [targetMarker], the camera auto-fits to the circle
/// (recomputed whenever [center]/[radiusM] change) so it fills the
/// viewport at any radius instead of sitting at a fixed zoom that over- or
/// under-fills depending on the radius (#60). [targetMarker]/[targetLabel]
/// are the soft-punishment map's addition (#18): the target's exact
/// location, outside the circle by definition, and that caller keeps its
/// original fixed-zoom-on-target framing — auto-fit only applies to the
/// geofence-only preview this was originally built for.
class GeofenceMap extends StatefulWidget {
  const GeofenceMap({
    required this.center,
    required this.radiusM,
    this.targetMarker,
    this.targetLabel,
    this.interactive = false,
    super.key,
  });

  final LatLng center;
  final double radiusM;
  final LatLng? targetMarker;
  final String? targetLabel;

  /// Enables pan/zoom for looking around — never repositioning the center.
  final bool interactive;

  @override
  State<GeofenceMap> createState() => _GeofenceMapState();
}

class _GeofenceMapState extends State<GeofenceMap> {
  final _mapController = MapController();

  @override
  void didUpdateWidget(GeofenceMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetMarker == null &&
        (oldWidget.center != widget.center ||
            oldWidget.radiusM != widget.radiusM)) {
      _fitToCircle();
    }
  }

  void _fitToCircle() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _boundsFor(widget.center, widget.radiusM),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  /// Bounding box of the circle — good enough at play-area scale (tens of
  /// meters to a couple km) without pulling in a full geodesy library.
  LatLngBounds _boundsFor(LatLng center, double radiusM) {
    const metersPerDegreeLat = 111320.0;
    final dLat = radiusM / metersPerDegreeLat;
    final metersPerDegreeLng =
        metersPerDegreeLat * math.cos(center.latitudeInRad);
    final dLng = radiusM / metersPerDegreeLng;
    return LatLngBounds(
      LatLng(center.latitude - dLat, center.longitude - dLng),
      LatLng(center.latitude + dLat, center.longitude + dLng),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.targetMarker;
    final center = widget.center;
    final radiusM = widget.radiusM;
    final danger = Theme.of(context).extension<GameColors>()?.danger;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: target ?? center,
        initialZoom: 15,
        interactionOptions: widget.interactive
            ? const InteractionOptions()
            : const InteractionOptions(flags: InteractiveFlag.none),
        // Deferred a frame: calling fitCamera synchronously from
        // onMapReady, before the first frame commits, left TileLayer
        // never subscribing to tile loads — an empty gray map, no error,
        // reproduced and root-caused live. Waiting for the first frame to
        // land fixes it.
        onMapReady: target == null
            ? () => WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _fitToCircle();
              })
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
            if (target != null)
              Marker(
                point: target,
                width: 140,
                height: 56,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.targetLabel != null)
                      Text(
                        widget.targetLabel!,
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
