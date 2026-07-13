import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:latlong2/latlong.dart';

import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/location/compass_math.dart';
import '../../../../core/location/heading.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../../domain/geofence_info.dart';
import '../../domain/target.dart';
import 'frame_confirm_page.dart';
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
      gameId: session.gameId,
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
      child: _IngameView(
        geofence: _geofence,
        selfPositionStream: _locationService.positionStream,
      ),
    );
  }
}

class _IngameView extends StatelessWidget {
  const _IngameView({required this.geofence, required this.selfPositionStream});

  final GeofenceInfo? geofence;
  final Stream<Position> selfPositionStream;

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
                    frameStatus: state.frameStatus,
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
                  IngameDead(
                    :final cause,
                    :final killerName,
                    :final survivedSeconds,
                    :final photoBytes,
                  ) =>
                    _DeadScreen(
                      cause: cause,
                      killerName: killerName,
                      survivedSeconds: survivedSeconds,
                      photoBytes: photoBytes,
                    ),
                },
                if (state.warning case final warning?)
                  _WarningOverlay(warning: warning),
                // Only ever shown while state.warning is null — the proximity
                // nudge clears itself the moment a player actually leaves
                // (is_near_geofence_edge requires "not outside" server-side),
                // so the two never compete for the same screen space.
                if (state.nearGeofenceEdge && state.warning == null)
                  const _ProximityBanner(),
                if (state.judgingQueue.isNotEmpty)
                  _JudgingOverlay(entry: state.judgingQueue.first),
                // Available in both dispersing and playing — the geofence
                // rule already applies during dispersal (tick_punishments
                // runs for both statuses), not just once a target's
                // assigned. Hidden once dead: nothing left to navigate by.
                if (geofence != null && state.phase is! IngameDead)
                  _MyLocationButton(
                    geofence: geofence!,
                    selfPositionStream: selfPositionStream,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How you died, how long you survived, the photo that framed you, and who
/// your assassin was (#23, IDEA.md "Screens" — death screen). Dead chat
/// (#24) is a separate panel this screen doesn't own yet.
class _DeadScreen extends StatelessWidget {
  const _DeadScreen({
    required this.cause,
    required this.killerName,
    required this.survivedSeconds,
    required this.photoBytes,
  });

  final String cause;
  final String? killerName;
  final int survivedSeconds;
  final Uint8List? photoBytes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (photoBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.memory(photoBytes!, fit: BoxFit.cover),
                  ),
                ),
              ),
            Text(
              cause == 'mia' ? t.ingame.deadTitleMia : t.ingame.deadTitleFramed,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (cause == 'mia')
              Text(t.ingame.deadCauseMia, textAlign: TextAlign.center)
            else if (killerName != null)
              Text(
                t.ingame.deadKilledBy(name: killerName!),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              t.ingame.deadSurvivedFor(time: _formatSurvived(survivedSeconds)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSurvived(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
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

/// The proactive edge nudge (#61): still inside the geofence, but close to
/// leaving it. Deliberately lightweight compared to [_WarningOverlay] — a
/// dismissable-by-nature banner, not a blocking full-screen modal, since
/// nothing is actually being punished yet.
class _ProximityBanner extends StatelessWidget {
  const _ProximityBanner();

  @override
  Widget build(BuildContext context) {
    final warningColor = Theme.of(context).extension<GameColors>()!.warning;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: warningColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: warningColor),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_circle_left_outlined, color: warningColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.ingame.nearGeofenceEdge,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: warningColor),
                ),
              ),
            ],
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
class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({
    required this.geofence,
    required this.selfPositionStream,
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
          padding: const EdgeInsets.all(8),
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

/// The judging modal (#22): frame photo next to the target's reference
/// selfie, "Is this {name}?", one tap on either icon casts the vote and
/// closes. Only ever shows the queue's front entry — a second pending
/// frame from another assassin waits its turn (see [IngameJudgingEntry]).
class _JudgingOverlay extends StatelessWidget {
  const _JudgingOverlay({required this.entry});

  final IngameJudgingEntry entry;

  @override
  Widget build(BuildContext context) {
    final alive = Theme.of(context).extension<GameColors>()!.alive;
    final danger = Theme.of(context).extension<GameColors>()!.danger;
    final bloc = context.read<IngameBloc>();
    final loaded = entry.loaded;

    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: loaded == null
                ? Center(
                    child: entry.failed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.ingame.judgingLoadError,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: bloc.retryFrontLoad,
                                child: Text(t.ingame.judgingRetry),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.ingame.judgingTitle(name: loaded.targetName),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  loaded.photoBytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  loaded.targetSelfieBytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.ingame.judgingNudge,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: danger,
                              ),
                              onPressed: () => bloc.castVote(
                                frameId: entry.frameId,
                                vote: false,
                              ),
                              icon: const Icon(Icons.close),
                              label: Text(t.ingame.judgingNo),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: alive,
                              ),
                              onPressed: () => bloc.castVote(
                                frameId: entry.frameId,
                                vote: true,
                              ),
                              icon: const Icon(Icons.check),
                              label: Text(t.ingame.judgingYes),
                            ),
                          ),
                        ],
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
    required this.frameStatus,
  });

  final Target target;
  final IngameCompass? compass;
  final bool hasWarning;
  final IngameTargetLocation? targetLocation;
  final GeofenceInfo? geofence;
  final IngameFrameStatus frameStatus;

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
          _FrameButton(status: frameStatus),
        ],
      ),
    );
  }
}

/// The frame button (#21): ready to shoot, waiting on a verdict (held and
/// pending look identical by design — see #19), or cooling down from a
/// failed vote. The cooldown clock is the bloc's, not this widget's — it
/// just renders whatever `until` the server sent.
class _FrameButton extends StatelessWidget {
  const _FrameButton({required this.status});

  final IngameFrameStatus status;

  Future<void> _openCamera(BuildContext context) async {
    final bloc = context.read<IngameBloc>();
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) =>
            const InAppCameraPage(lensDirection: CameraLensDirection.back),
      ),
    );
    if (bytes == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FrameConfirmPage(photoBytes: bytes, bloc: bloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      FrameReady() => FilledButton.icon(
        onPressed: () => _openCamera(context),
        icon: const Icon(Icons.camera_alt),
        label: Text(t.frame.button),
      ),
      FrameWaitingForVerdict() => FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty),
        label: Text(t.frame.waiting),
      ),
      FrameCooldown(:final until) => _CountdownText(
        deadline: until,
        builder: (context, time) => FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.timer_outlined),
          label: Text(t.frame.cooldown(time: time)),
        ),
      ),
    };
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
