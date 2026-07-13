import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../i18n/strings.g.dart';
import 'geofence_map.dart';

/// Full-screen, freely pannable/zoomable look at the play area (#60) — for
/// judging what's inside vs. outside the boundary, never for repositioning
/// it (the center still always tracks GPS, per #43). Pop with no return
/// value; nothing here is editable.
class GeofenceMapViewerPage extends StatelessWidget {
  const GeofenceMapViewerPage({
    required this.center,
    required this.radiusM,
    super.key,
  });

  final LatLng center;
  final double radiusM;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.hostSetup.geofenceSectionTitle)),
      body: GeofenceMap(center: center, radiusM: radiusM, interactive: true),
    );
  }
}
