import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:latlong2/latlong.dart';

import 'package:flutter_compass/flutter_compass.dart';

import '../../../../core/audio/game_sounds.dart';
import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/chat/chat_message.dart';
import '../../../../core/chat/chat_panel.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/location/compass_math.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/wake_lock_service.dart';
import '../../../../core/push/local_alarms.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/framed_icons.dart';
import '../../../../core/theme/motion.dart';
import '../../../../core/util/duration_format.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/full_screen_photo_page.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../../domain/geofence_info.dart';
import '../../domain/target.dart';
import 'frame_confirm_page.dart';
import 'ingame_bloc.dart';
import 'ingame_state.dart';
import '../../../../core/theme/spacing.dart';

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
  late final StreamSubscription<GameEvent> _gameFinishedSub;

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
    // game:{game_id} gets the same treatment: LocationService and this
    // page's own game_finished navigation (#26) both listen to it.
    final playerEvents = channels.player(session.playerId).asBroadcastStream();
    final gameEvents = channels.game(session.gameId).asBroadcastStream();
    _bloc = IngameBloc(
      events: playerEvents,
      crypto: session.crypto,
      repository: repository,
      localAlarms: getIt<LocalAlarms>(),
      session: session,
      wakeLockService: getIt<WakeLockService>(),
      sounds: getIt<GameSounds>(),
      deadChatEvents: channels.deadChat(session.gameId),
      gameId: session.gameId,
      myPlayerId: session.playerId,
      initialEndsAt: widget.initialEndsAt,
    );
    _locationService = LocationService(
      repository: repository,
      gameId: session.gameId,
      gameEvents: gameEvents,
      playerEvents: playerEvents,
    )..start();
    // The finish screen is reachable from any ingame phase — dispersing,
    // playing, mid-warning, mid-judging, even already dead (#26). The
    // isActive check guards a real race (#78): leaving while alive can
    // itself end the game (tick_min_players_check), and this device is
    // still subscribed to game:{game_id} until dispose() below runs — a
    // game_finished broadcast that lands in that window, after leave()
    // has already cleared the session but before this page unmounts,
    // would otherwise try to build FinishPage against a null session and
    // crash on the null-check getters in GameSession.
    _gameFinishedSub = gameEvents.listen((event) {
      if (event is GameFinished && mounted && getIt<GameSession>().isActive) {
        context.go('/finish', extra: event);
      }
    });
    repository
        .getGeofence(session.gameId)
        .then((geofence) {
          if (mounted) setState(() => _geofence = geofence);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _gameFinishedSub.cancel();
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
        child: BlocListener<IngameBloc, IngameState>(
          // Backstop for the get_my_state catch-up finding the game
          // already finished (#89) — same isActive guard and destination
          // as IngamePage's own game:{game_id} broadcast listener, for a
          // channel that went stale before that broadcast ever arrived.
          listenWhen: (previous, current) =>
              previous.pendingFinish == null && current.pendingFinish != null,
          listener: (context, state) {
            if (getIt<GameSession>().isActive) {
              context.go('/finish', extra: state.pendingFinish);
            }
          },
          child: BlocBuilder<IngameBloc, IngameState>(
            builder: (context, state) => PopScope(
              // Unmissable per IDEA.md "Screens" (warning modal) — the back
              // gesture can't dismiss it, only the server clearing the rule
              // break can. Once dead, back can pop freely — the death
              // screen's own Leave button already handles that safely, no
              // live-game consequence left to confirm. Otherwise (#82),
              // route through the same confirmation the corner Leave
              // button uses instead of silently backgrounding/exiting —
              // that used to leave a player "alive" server-side, untracked,
              // with no indication anything happened.
              canPop: state.warning == null && state.phase is IngameDead,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop || state.warning != null) return;
                await _confirmAndLeaveIngame(
                  context,
                  title: t.ingame.leaveConfirmTitle,
                  message: t.ingame.leaveConfirmBody,
                  confirmLabel: t.ingame.leaveConfirmButton,
                );
              },
              child: Stack(
                children: [
                  switch (state.phase) {
                    IngameDispersing(:final endsAt) => _DisperseCountdown(
                      endsAt: endsAt,
                    ),
                    IngamePlaying(:final target) => _TargetCard(
                      target: target,
                      compass: state.compass,
                      nextPulseAt: state.nextPulseAt,
                      hasWarning: state.warning != null,
                      targetLocation: state.targetLocation,
                      geofence: geofence,
                      frameStatus: state.frameStatus,
                    ),
                    IngameTargetLoadFailed() => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.xl),
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
                        chat: state.deadChat,
                        otherDeadPlayerNames: state.otherDeadPlayerNames,
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
                  if (state.myName case final myName?
                      when state.phase is! IngameDead)
                    _SelfNameLabel(name: myName),
                  // The death screen has its own dedicated leave button in
                  // its content flow (#77) — this corner button covers the
                  // two phases before that, dispersing and playing (#78:
                  // "no mid-game quit" no longer blocks the living, it just
                  // makes leaving cost you the game).
                  if (state.phase is! IngameDead) const _LeaveButton(),
                  // Nothing left to stay awake for once dead (#78) — no more
                  // compass pulses or warnings, and a pending frame_to_judge
                  // still wakes the device via its own push either way.
                  if (state.phase is! IngameDead)
                    _WakeLockButton(keepAwake: state.keepAwake),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How you died, how long you survived, the photo that framed you, who your
/// assassin was (#23), and the dead chat everyone out of the game shares
/// (#24, IDEA.md "Screens" — death screen).
class _DeadScreen extends StatelessWidget {
  const _DeadScreen({
    required this.cause,
    required this.killerName,
    required this.survivedSeconds,
    required this.photoBytes,
    required this.chat,
    required this.otherDeadPlayerNames,
  });

  final String cause;
  final String? killerName;
  final int survivedSeconds;
  final Uint8List? photoBytes;
  final List<ChatMessage> chat;
  final List<String> otherDeadPlayerNames;

  @override
  Widget build(BuildContext context) {
    final myPlayerId = getIt<GameSession>().playerId;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photoBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.lg),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _TappablePhoto(
                      bytes: photoBytes!,
                      radius: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                switch (cause) {
                  'mia' => t.ingame.deadTitleMia,
                  // Only reachable via a crash-resume racing the leave RPC
                  // itself (#78) — a normal leave ends the session and
                  // navigates home before this screen would ever render.
                  'left' => t.ingame.deadTitleLeft,
                  _ => t.ingame.deadTitleFramed,
                },
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Gap.lg,
              if (cause == 'mia')
                Text(t.ingame.deadCauseMia, textAlign: TextAlign.center)
              else if (cause == 'left')
                Text(t.ingame.deadCauseLeft, textAlign: TextAlign.center)
              else if (killerName != null)
                Text(
                  t.ingame.deadKilledBy(name: killerName!),
                  textAlign: TextAlign.center,
                ),
              Gap.sm,
              Text(
                t.ingame.deadSurvivedFor(time: formatDuration(survivedSeconds)),
                textAlign: TextAlign.center,
              ),
              if (otherDeadPlayerNames.isNotEmpty) ...[
                Gap.sm,
                Text(
                  t.ingame.deadAlsoOut(names: otherDeadPlayerNames.join(', ')),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              Gap.lg,
              Text(
                t.ingame.deadLeaveWarning,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              Gap.sm,
              // No leave option existed on this screen before #77 — only
              // force-closing the app. Dead-only: IDEA.md "Game rules"'
              // no-mid-game-quit still binds the living, this screen only
              // ever renders once already dead.
              OutlinedButton.icon(
                onPressed: () => _confirmAndLeaveIngame(
                  context,
                  title: t.ingame.deadLeaveConfirmTitle,
                  message: t.ingame.deadLeaveConfirmBody,
                  confirmLabel: t.ingame.deadLeaveConfirmButton,
                ),
                icon: const Icon(Icons.logout),
                label: Text(t.ingame.deadLeaveButton),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SafeArea(
            top: false,
            child: ChatPanel(
              chat: chat,
              myPlayerId: myPlayerId,
              onSend: (text) =>
                  context.read<IngameBloc>().sendChatMessage(text),
              emptyText: t.ingame.deadChatEmpty,
              hintText: t.ingame.deadChatHint,
              sendTooltip: t.ingame.deadChatSendButton,
              listPadding: const EdgeInsets.symmetric(
                horizontal: Space.lg,
                vertical: Space.sm,
              ),
            ),
          ),
        ),
      ],
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
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FramedIcons(FramedIcon.warning, size: 48, color: danger),
                Gap.lg,
                for (final reason in warning.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.md),
                    child: Text(
                      _reasonText(reason),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                Gap.lg,
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
          margin: const EdgeInsets.all(Space.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          decoration: BoxDecoration(
            color: warningColor.withValues(alpha: 0.15),
            borderRadius: AppTheme.corner,
            border: Border.all(color: warningColor),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_circle_left_outlined, color: warningColor),
              HGap.md,
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

/// A reminder of which player you are (#73) — the reference selfie and
/// target card are all about the target, nothing on this screen otherwise
/// names the device's own player. Mirrors [_MyLocationButton]'s corner
/// placement on the opposite side.
class _SelfNameLabel extends StatelessWidget {
  const _SelfNameLabel({required this.name});

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

/// Leave via [IngameBloc], confirmed first (#77, #92) — the server kills
/// you (cause 'left') and relinks the circle exactly like any other death
/// when still alive, or just ends the session once already dead. Shared
/// by the corner button, the back gesture (#82), and the death screen's
/// own leave button — same shape every time, just different copy.
Future<void> _confirmAndLeaveIngame(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) => confirmAndLeave(
  context: context,
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  onConfirmed: (context) async {
    final succeeded = await context.read<IngameBloc>().leave();
    // #88: the dialog above promises an immediate consequence (frame
    // judging stops / a relink, possibly ending the game) — surface it
    // when the server never actually confirmed that, rather than
    // navigating home as if it had.
    if (!succeeded && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.ingame.leaveNetworkWarning)));
    }
  },
);

/// Bottom-left corner: the only one of the four still free (_SelfNameLabel
/// top-left, _MyLocationButton top-right, the wake lock toggle
/// bottom-right).
class _LeaveButton extends StatelessWidget {
  const _LeaveButton();

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
            onPressed: () => _confirmAndLeaveIngame(
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
/// overlays (_SelfNameLabel, _MyLocationButton) both sit at the top.
class _WakeLockButton extends StatelessWidget {
  const _WakeLockButton({required this.keepAwake});

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
            padding: const EdgeInsets.all(Space.xl),
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
                              Gap.lg,
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
                      Gap.lg,
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _TappablePhoto(
                                bytes: loaded.photoBytes,
                                radius: 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            HGap.sm,
                            Expanded(
                              child: _TappablePhoto(
                                bytes: loaded.targetSelfieBytes,
                                radius: 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.sm,
                      Text(
                        t.ingame.judgingNudge,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Gap.lg,
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: AppTheme.semanticFilled(danger),
                              onPressed: () => bloc.castVote(
                                frameId: entry.frameId,
                                vote: false,
                              ),
                              icon: const Icon(Icons.close),
                              label: Text(t.ingame.judgingNo),
                            ),
                          ),
                          HGap.lg,
                          Expanded(
                            child: FilledButton.icon(
                              style: AppTheme.semanticFilled(alive),
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
          Gap.lg,
          _CountdownText(
            deadline: endsAt,
            builder: (context, time) =>
                Text(time, style: Theme.of(context).textTheme.displayLarge),
          ),
          Gap.lg,
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
    required this.nextPulseAt,
    required this.hasWarning,
    required this.targetLocation,
    required this.geofence,
    required this.frameStatus,
  });

  final Target target;
  final IngameCompass? compass;
  final DateTime? nextPulseAt;
  final bool hasWarning;
  final IngameTargetLocation? targetLocation;
  final GeofenceInfo? geofence;
  final IngameFrameStatus frameStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.ingame.targetCardTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Gap.lg,
          // BoxFit.cover at a fixed height cropped portrait selfies down to
          // a near-square sliver — contain (still capped) shows the whole
          // photo instead.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: _TappablePhoto(
              bytes: target.selfieBytes,
              radius: 16,
              fit: BoxFit.contain,
            ),
          ),
          Gap.lg,
          Text(
            target.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Gap.xl,
          _CompassPanel(
            compass: compass,
            nextPulseAt: nextPulseAt,
            hasWarning: hasWarning,
          ),
          if (targetLocation case final location?)
            if (geofence case final geofence?) ...[
              Gap.xl,
              _TargetLocationPanel(location: location, geofence: geofence),
            ],
          Gap.xl,
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
        icon: const FramedIcons(FramedIcon.frame),
        label: Text(t.frame.button),
      ),
      FrameWaitingForVerdict() => FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty),
        label: Text(t.frame.waiting),
      ),
      FrameCooldown(:final until, :final reason) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (switch (reason) {
                'rejected' => t.frame.cooldownReasonRejected,
                'timeout' => t.frame.cooldownReasonTimeout,
                _ => null,
              }
              case final reasonText?) ...[
            Text(
              reasonText,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Gap.xs,
          ],
          _CountdownText(
            deadline: until,
            builder: (context, time) => FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.timer_outlined),
              label: Text(t.frame.cooldown(time: time)),
            ),
          ),
        ],
      ),
    };
  }
}

/// The compass area (#17). No-pulse states are one line each: rule-breaking
/// ties into #15's warning; otherwise a live countdown to [nextPulseAt]
/// (#73) once the server has told this device when that is — a static
/// "soon" only remains for the narrow window before that's ever arrived
/// (get_my_state hasn't resolved yet, or this is a lobby/dispersing game
/// with no schedule at all).
class _CompassPanel extends StatelessWidget {
  const _CompassPanel({
    required this.compass,
    required this.nextPulseAt,
    required this.hasWarning,
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
    return _CountdownText(
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
        Gap.sm,
        ClipRRect(
          borderRadius: AppTheme.corner,
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

/// A rounded, tappable photo that opens full-screen on tap (#94) — the
/// death screen's frame photo, both judging-overlay photos, and the
/// target card's selfie all shared this exact shape (differing only in
/// corner radius and [BoxFit]). Sizing (aspect ratio, max height) is the
/// caller's concern, wrapped around this widget rather than baked in.
class _TappablePhoto extends StatelessWidget {
  const _TappablePhoto({
    required this.bytes,
    required this.radius,
    required this.fit,
  });

  final Uint8List bytes;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FullScreenPhotoPage.open(context, bytes),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(bytes, fit: fit),
      ),
    );
  }
}
