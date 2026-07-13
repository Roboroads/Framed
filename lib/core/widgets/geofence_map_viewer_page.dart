import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../i18n/strings.g.dart';
import 'geofence_map.dart';

/// Full-screen, freely pannable/zoomable look at the play area (#60) — for
/// judging what's inside vs. outside the boundary, never for repositioning
/// it (the center still always tracks GPS, per #43). Pop with no return
/// value; nothing here is editable.
///
/// [selfPositionStream], when given, overlays the player's own live
/// position (#65) — a stream rather than a one-shot [LatLng] so the marker
/// tracks them for as long as this page stays open, not just a snapshot
/// from the moment it was opened.
class GeofenceMapViewerPage extends StatelessWidget {
  const GeofenceMapViewerPage({
    required this.center,
    required this.radiusM,
    this.selfPositionStream,
    this.initialSelfPosition,
    super.key,
  });

  final LatLng center;
  final double radiusM;
  final Stream<LatLng>? selfPositionStream;
  final LatLng? initialSelfPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selfPositionStream == null
              ? t.hostSetup.geofenceSectionTitle
              : t.ingame.myLocationTitle,
        ),
      ),
      body: selfPositionStream == null
          ? GeofenceMap(center: center, radiusM: radiusM, interactive: true)
          : StreamBuilder<LatLng>(
              initialData: initialSelfPosition,
              stream: selfPositionStream,
              builder: (context, snapshot) => GeofenceMap(
                center: center,
                radiusM: radiusM,
                interactive: true,
                selfMarker: snapshot.data,
              ),
            ),
    );
  }
}
