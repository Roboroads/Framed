import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../../../core/location/compass_math.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/motion.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_state.dart';
import 'countdown_text.dart';

/// The compass area (#17). No-pulse states are one line each: rule-breaking
/// ties into #15's warning; otherwise a live countdown to [nextPulseAt]
/// (#73) once the server has told this device when that is — a static
/// "soon" only remains for the narrow window before that's ever arrived
/// (get_my_state hasn't resolved yet, or this is a lobby/dispersing game
/// with no schedule at all).
class CompassPanel extends StatelessWidget {
  const CompassPanel({
    required this.compass,
    required this.nextPulseAt,
    required this.hasWarning,
    super.key,
  });

  final IngameCompass? compass;
  final DateTime? nextPulseAt;
  final bool hasWarning;

  @override
  Widget build(BuildContext context) {
    final compass = this.compass;
    if (compass != null) return _CompassArrow(compass: compass);
    if (hasWarning) {
      return Text(
        t.ingame.compassNoPulseWarning,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final nextPulseAt = this.nextPulseAt;
    if (nextPulseAt == null || !nextPulseAt.isAfter(DateTime.now())) {
      return Text(
        t.ingame.compassNoPulseIdle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return CountdownText(
      deadline: nextPulseAt,
      builder: (context, time) => Text(
        t.ingame.compassNoPulseCountdown(time: time),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _CompassArrow extends StatefulWidget {
  const _CompassArrow({required this.compass});

  final IngameCompass compass;

  @override
  State<_CompassArrow> createState() => _CompassArrowState();
}

class _CompassArrowState extends State<_CompassArrow> {
  final _rotation = RotationTracker();
  late final Timer _ticker;

  // Device heading in degrees (0-360, 0 = north, #98). Devices with no
  // usable sensor simply never emit — the StreamBuilder below falls back
  // to text after a timeout.
  final Stream<double> _headingStream =
      FlutterCompass.events
          ?.map((e) => e.heading)
          .where((h) => h != null)
          .cast<double>() ??
      const Stream.empty();

  @override
  void initState() {
    super.initState();
    // Redraws the countdown bar; the panel's own disappearance is driven
    // by IngameBloc clearing state.compass on expiry, not by this timer.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compassColor = Theme.of(context).extension<GameColors>()!.compass;
    final total = widget.compass.expiresAt.difference(
      widget.compass.receivedAt,
    );
    final remaining = widget.compass.expiresAt.difference(DateTime.now());
    final progress = total.inMilliseconds > 0
        ? (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final distance = roundDistanceMeters(widget.compass.distanceM);

    return StreamBuilder<double>(
      stream: _headingStream,
      builder: (context, snapshot) {
        final heading = snapshot.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (heading == null)
              Text(
                t.ingame.compassFallback(
                  direction: cardinalDirection(widget.compass.bearingDeg),
                  distance: distance,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: compassColor),
              )
            else ...[
              // The needle turns inside a viewfinder that doesn't: the
              // housing is the app's own mark, held still, so the only
              // thing moving is the one thing that means anything.
              Stack(
                alignment: Alignment.center,
                children: [
                  FramedIcons(
                    FramedIcon.reticle,
                    size: 72,
                    color: compassColor.withValues(alpha: 0.45),
                  ),
                  AnimatedRotation(
                    turns:
                        _rotation.update(
                          compassArrowAngle(
                            targetBearingDeg: widget.compass.bearingDeg,
                            headingDeg: heading,
                          ),
                        ) /
                        360,
                    duration: Motion.gate(context, Motion.standard),
                    child: FramedIcons(
                      FramedIcon.compass,
                      size: 40,
                      color: compassColor,
                    ),
                  ),
                ],
              ),
              Gap.sm,
              Text(
                t.ingame.compassDistanceMeters(distance: distance),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: compassColor),
              ),
            ],
            Gap.sm,
            ClipRRect(
              borderRadius: AppTheme.corner,
              child: LinearProgressIndicator(
                value: progress,
                color: compassColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
