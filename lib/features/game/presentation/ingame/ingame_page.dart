import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/location/compass_math.dart';
import '../../../../core/location/heading.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../../domain/geofence_info.dart';
import '../../domain/target.dart';
import 'ingame_bloc.dart';
import 'ingame_state.dart';

/// Lands here from the lobby (#10) on `dispersal_started`, behind the
/// background location gate (#14).
class IngamePage extends StatefulWidget {
  const IngamePage({required this.initialEndsAt, super.key});

  final DateTime initialEndsAt;

  @override
  State<IngamePage> createState() => _IngamePageState();
}

class _IngamePageState extends State<IngamePage> {
  late final IngameBloc _bloc;
  late final LocationService _locationService;

  // Fetched once — the geofence is set at host setup and static for the
  // whole game. Null until it resolves (or forever, on failure): the
  // soft-punishment panel (#18) just stays hidden until then.
  GeofenceInfo? _geofence;

  @override
  void initState() {
    super.initState();
    final session = getIt<GameSession>();
    final channels = getIt<GameChannels>();
    final repository = getIt<GameRepository>();
    // One subscription to player:{id}, shared by both consumers below —
    // two separate channel joins to the same topic confused the realtime
    // server into dropping broadcasts on it (#15 discovered this live).
    final playerEvents = channels.player(session.playerId).asBroadcastStream();
    _bloc = IngameBloc(
      events: playerEvents,
      crypto: session.crypto,
      repository: repository,
      initialEndsAt: widget.initialEndsAt,
    );
    _locationService = LocationService(
      repository: repository,
      gameId: session.gameId,
      gameEvents: channels.game(session.gameId),
      playerEvents: playerEvents,
    )..start();
    repository
        .getGeofence(session.gameId)
        .then((geofence) {
          if (mounted) setState(() => _geofence = geofence);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _locationService.stop();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: _IngameView(geofence: _geofence),
    );
  }
}

class _IngameView extends StatelessWidget {
  const _IngameView({required this.geofence});

  final GeofenceInfo? geofence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<IngameBloc, IngameState>(
          builder: (context, state) => PopScope(
            // Unmissable per IDEA.md "Screens" (warning modal) — the back
            // gesture can't dismiss it, only the server clearing the rule
            // break can.
            canPop: state.warning == null,
            child: Stack(
              children: [
                switch (state.phase) {
                  IngameDispersing(:final endsAt) => _DisperseCountdown(
                    endsAt: endsAt,
                  ),
                  IngamePlaying(:final target) => _TargetCard(
                    target: target,
                    compass: state.compass,
                    hasWarning: state.warning != null,
                    targetLocation: state.targetLocation,
                    geofence: geofence,
                  ),
                  IngameTargetLoadFailed() => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t.ingame.errorTargetLoad,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                },
                if (state.warning case final warning?)
                  _WarningOverlay(warning: warning),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ticks once a second and renders the mm:ss remaining until [deadline] —
/// shared by the warning overlay and the dispersal countdown, the only two
/// places that need a live countdown.
class _CountdownText extends StatefulWidget {
  const _CountdownText({required this.deadline, required this.builder});

  final DateTime deadline;
  final Widget Function(BuildContext context, String time) builder;

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText> {
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
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
    final remaining = widget.deadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return widget.builder(context, '$minutes:$seconds');
  }
}

class _WarningOverlay extends StatelessWidget {
  const _WarningOverlay({required this.warning});

  final IngameWarning warning;

  String _reasonText(String reason) => switch (reason) {
    'geofence' => t.ingame.warningGeofence,
    'stale' => t.ingame.warningStale,
    _ => reason,
  };

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).extension<GameColors>()!.danger;

    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 48, color: danger),
                const SizedBox(height: 16),
                for (final reason in warning.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _reasonText(reason),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                const SizedBox(height: 16),
                _CountdownText(
                  deadline: warning.hardDeadline,
                  builder: (context, time) => Text(
                    t.ingame.warningDeadline(time: time),
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: danger),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisperseCountdown extends StatelessWidget {
  const _DisperseCountdown({required this.endsAt});

  final DateTime endsAt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.ingame.disperseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _CountdownText(
            deadline: endsAt,
            builder: (context, time) =>
                Text(time, style: Theme.of(context).textTheme.displayLarge),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              t.ingame.disperseInstruction,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.compass,
    required this.hasWarning,
    required this.targetLocation,
    required this.geofence,
  });

  final Target target;
  final IngameCompass? compass;
  final bool hasWarning;
  final IngameTargetLocation? targetLocation;
  final GeofenceInfo? geofence;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.ingame.targetCardTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              target.selfieBytes,
              height: 320,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            target.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _CompassPanel(compass: compass, hasWarning: hasWarning),
          if (targetLocation case final location?)
            if (geofence case final geofence?) ...[
              const SizedBox(height: 24),
              _TargetLocationPanel(location: location, geofence: geofence),
            ],
          const SizedBox(height: 24),
          // Placeholder for #21 — the frame camera wires this up.
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.camera_alt),
            label: Text(t.ingame.frameButtonPlaceholder),
          ),
        ],
      ),
    );
  }
}

/// The compass area (#17). No-pulse states are one line each: rule-breaking
/// ties into #15's warning, otherwise idle text — the client never computes
/// when the next pulse is due, only the server knows.
class _CompassPanel extends StatelessWidget {
  const _CompassPanel({required this.compass, required this.hasWarning});

  final IngameCompass? compass;
  final bool hasWarning;

  @override
  Widget build(BuildContext context) {
    final compass = this.compass;
    if (compass == null) {
      return Text(
        hasWarning
            ? t.ingame.compassNoPulseWarning
            : t.ingame.compassNoPulseIdle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return _CompassArrow(compass: compass);
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
  final _heading = Heading();
  late final Timer _ticker;

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
      stream: _heading.stream,
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
              AnimatedRotation(
                turns:
                    _rotation.update(
                      compassArrowAngle(
                        targetBearingDeg: widget.compass.bearingDeg,
                        headingDeg: heading,
                      ),
                    ) /
                    360,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.navigation, size: 48, color: compassColor),
              ),
              const SizedBox(height: 8),
              Text(
                t.ingame.compassDistanceMeters(distance: distance),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: compassColor),
              ),
            ],
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
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

/// The soft-punishment target map (#18) — only the target's assassin ever
/// receives target_location, so this panel only ever renders for them.
class _TargetLocationPanel extends StatelessWidget {
  const _TargetLocationPanel({required this.location, required this.geofence});

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
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
