import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/location/compass_math.dart';
import '../../../../core/location/heading.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
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
  }

  @override
  void dispose() {
    _locationService.stop();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _bloc, child: const _IngameView());
  }
}

class _IngameView extends StatelessWidget {
  const _IngameView();

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

class _WarningOverlay extends StatefulWidget {
  const _WarningOverlay({required this.warning});

  final IngameWarning warning;

  @override
  State<_WarningOverlay> createState() => _WarningOverlayState();
}

class _WarningOverlayState extends State<_WarningOverlay> {
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

  String _reasonText(String reason) => switch (reason) {
    'geofence' => t.ingame.warningGeofence,
    'stale' => t.ingame.warningStale,
    _ => reason,
  };

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).extension<GameColors>()!.danger;
    final remaining = widget.warning.hardDeadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');

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
                for (final reason in widget.warning.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _reasonText(reason),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  t.ingame.warningDeadline(time: '$minutes:$seconds'),
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: danger),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisperseCountdown extends StatefulWidget {
  const _DisperseCountdown({required this.endsAt});

  final DateTime endsAt;

  @override
  State<_DisperseCountdown> createState() => _DisperseCountdownState();
}

class _DisperseCountdownState extends State<_DisperseCountdown> {
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
    final remaining = widget.endsAt.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.ingame.disperseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            '$minutes:$seconds',
            style: Theme.of(context).textTheme.displayLarge,
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
  });

  final Target target;
  final IngameCompass? compass;
  final bool hasWarning;

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
  const _CompassPanel({
    required this.compass,
    required this.hasWarning,
    @visibleForTesting Heading? heading,
  }) : _heading = heading;

  final IngameCompass? compass;
  final bool hasWarning;
  final Heading? _heading;

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
    return _CompassArrow(compass: compass, heading: _heading ?? Heading());
  }
}

class _CompassArrow extends StatefulWidget {
  const _CompassArrow({required this.compass, required this.heading});

  final IngameCompass compass;
  final Heading heading;

  @override
  State<_CompassArrow> createState() => _CompassArrowState();
}

class _CompassArrowState extends State<_CompassArrow> {
  final _rotation = RotationTracker();
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
      stream: widget.heading.stream,
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
