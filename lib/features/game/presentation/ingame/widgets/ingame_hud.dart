import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../domain/geofence_info.dart';
import '../ingame_bloc.dart';
import 'leave_ingame.dart';

/// A reminder of which player you are (#73) — the reference selfie and
/// target card are all about the target, nothing on this screen otherwise
/// names the device's own player. Mirrors [MyLocationButton]'s corner
/// placement on the opposite side.
class SelfNameLabel extends StatelessWidget {
  const SelfNameLabel({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Text(
            t.ingame.selfNameLabel(name: name),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

/// Bottom-left corner: the only one of the four still free (SelfNameLabel
/// top-left, MyLocationButton top-right, the wake lock toggle
/// bottom-right).
class LeaveButton extends StatelessWidget {
  const LeaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: FloatingActionButton.small(
            heroTag: 'leave',
            tooltip: t.ingame.leaveButton,
            onPressed: () => confirmAndLeaveIngame(
              context,
              title: t.ingame.leaveConfirmTitle,
              message: t.ingame.leaveConfirmBody,
              confirmLabel: t.ingame.leaveConfirmButton,
            ),
            child: const Icon(Icons.logout),
          ),
        ),
      ),
    );
  }
}

/// Quick on/off for keeping the screen from auto-locking (#78), on by
/// default (IngameState.keepAwake) so a compass pulse or warning is never
/// missed to a dimmed screen. Bottom-right corner: the two other corner
/// overlays (SelfNameLabel, MyLocationButton) both sit at the top.
class WakeLockButton extends StatelessWidget {
  const WakeLockButton({required this.keepAwake, super.key});

  final bool keepAwake;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: FloatingActionButton.small(
            heroTag: 'wakeLock',
            tooltip: keepAwake
                ? t.ingame.wakeLockOnTooltip
                : t.ingame.wakeLockOffTooltip,
            onPressed: () => context.read<IngameBloc>().toggleKeepAwake(),
            child: Icon(keepAwake ? Icons.lightbulb : Icons.lightbulb_outline),
          ),
        ),
      ),
    );
  }
}

/// Opens a full-screen map with the player's own live position and the
/// play-area boundary (#65) — button rather than a persistent on-screen
/// map, since the "Game in progress" screen is already dense (target card,
/// compass, frame button, and the proximity banner from #61).
class MyLocationButton extends StatelessWidget {
  const MyLocationButton({
    required this.geofence,
    required this.selfPositionStream,
    super.key,
  });

  final GeofenceInfo geofence;
  final Stream<Position> selfPositionStream;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: FloatingActionButton.small(
            heroTag: 'myLocation',
            tooltip: t.ingame.myLocationButton,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GeofenceMapViewerPage(
                  center: LatLng(geofence.lat, geofence.lng),
                  radiusM: geofence.radiusM.toDouble(),
                  selfPositionStream: selfPositionStream.map(
                    (p) => LatLng(p.latitude, p.longitude),
                  ),
                ),
              ),
            ),
            child: const Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }
}
