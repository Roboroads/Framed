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

/// The compass area (#17), IDEA.md's signature moment: a global pulse fires
/// for everyone at once, and the whole point is that you stop and look.
///
/// Idle and active share one housing — the reticle. Idle it's dimmed with a
/// countdown to the next pulse; when the pulse lands the same housing lights
/// up, a live needle appears inside it, and the distance reads out. Sharing
/// the frame means the pulse resolves *into* the instrument instead of
/// shoving the layout around, which is what "everyone check now" should feel
/// like. No-pulse edge cases (rule-breaking, or before the first schedule
/// arrives) fall back to a line under the dimmed housing.
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

    final compassColor = Theme.of(context).extension<GameColors>()!.compass;
    final nextPulseAt = this.nextPulseAt;
    final counting =
        !hasWarning &&
        nextPulseAt != null &&
        nextPulseAt.isAfter(DateTime.now());

    return _CompassHousing(
      // Dimmed until a pulse lights it up.
      color: compassColor.withValues(alpha: 0.35),
      caption: counting
          ? CountdownText(
              deadline: nextPulseAt,
              builder: (context, time) => _Caption(
                t.ingame.compassNoPulseCountdown(time: time),
                mono: true,
              ),
            )
          : _Caption(
              hasWarning
                  ? t.ingame.compassNoPulseWarning
                  : t.ingame.compassNoPulseIdle,
            ),
    );
  }
}

/// The reticle that both states hang off. [needle] rotates inside it on a live
/// pulse; idle it's empty. [caption] is the line beneath — a countdown, a
/// distance, or a status note.
class _CompassHousing extends StatelessWidget {
  const _CompassHousing({
    required this.color,
    required this.caption,
    this.needle,
    this.progress,
  });

  final Color color;
  final Widget caption;
  final Widget? needle;

  /// Remaining view-time, 1..0, drawn as a bar under the caption. Null idle.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            FramedIcons(FramedIcon.reticle, size: 88, color: color),
            ?needle,
          ],
        ),
        Gap.md,
        caption,
        if (progress != null) ...[
          Gap.md,
          ClipRRect(
            borderRadius: AppTheme.corner,
            child: LinearProgressIndicator(value: progress, color: color),
          ),
        ],
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text, {this.mono = false, this.color});

  final String text;
  final bool mono;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium!;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: (mono ? AppTheme.mono(base) : base).copyWith(color: color),
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
        final housing = _CompassHousing(
          color: compassColor,
          progress: progress,
          // The needle turns inside a viewfinder that doesn't: the housing
          // is the app's own mark, held still, so the only thing moving is
          // the one thing that means anything. No sensor, no needle — the
          // caption carries the cardinal direction instead.
          needle: heading == null
              ? null
              : AnimatedRotation(
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
                    size: 44,
                    color: compassColor,
                  ),
                ),
          caption: heading == null
              // Plain, not mono: this line leads with a cardinal-direction
              // word, and mono/tabular figures are for numbers.
              ? _Caption(
                  t.ingame.compassFallback(
                    direction: cardinalDirection(widget.compass.bearingDeg),
                    distance: distance,
                  ),
                  color: compassColor,
                )
              // The distance is the point of the screen the instant a pulse
              // lands, so it gets a display role — big, mono, tabular.
              : Text(
                  t.ingame.compassDistanceMeters(distance: distance),
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: compassColor),
                ),
        );

        // A one-shot grow-and-fade as the pulse resolves into focus — the
        // camera catching, gated for reduced motion. TweenAnimationBuilder
        // keeps its controller across the 200ms ticker rebuilds, so this
        // plays once on mount (when the pulse arrives), not every tick.
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Motion.gate(context, Motion.standard),
          curve: Motion.enter,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
          ),
          child: housing,
        );
      },
    );
  }
}
