import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/game_sounds.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/wake_lock_service.dart';
import '../../../../core/push/local_alarms.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../../domain/geofence_info.dart';
import 'ingame_bloc.dart';
import 'ingame_state.dart';
import 'widgets/dead_screen.dart';
import 'widgets/disperse_countdown.dart';
import 'widgets/ingame_hud.dart';
import 'widgets/judging_overlay.dart';
import 'widgets/leave_ingame.dart';
import 'widgets/target_card.dart';
import 'widgets/warning_overlay.dart';

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
                await confirmAndLeaveIngame(
                  context,
                  title: t.ingame.leaveConfirmTitle,
                  message: t.ingame.leaveConfirmBody,
                  confirmLabel: t.ingame.leaveConfirmButton,
                );
              },
              child: Stack(
                children: [
                  switch (state.phase) {
                    IngameDispersing(:final endsAt) => DisperseCountdown(
                      endsAt: endsAt,
                    ),
                    IngamePlaying(:final target) => TargetCard(
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
                      DeadScreen(
                        cause: cause,
                        killerName: killerName,
                        survivedSeconds: survivedSeconds,
                        photoBytes: photoBytes,
                        chat: state.deadChat,
                        otherDeadPlayerNames: state.otherDeadPlayerNames,
                      ),
                  },
                  if (state.warning case final warning?)
                    WarningOverlay(warning: warning),
                  // Only ever shown while state.warning is null — the proximity
                  // nudge clears itself the moment a player actually leaves
                  // (is_near_geofence_edge requires "not outside" server-side),
                  // so the two never compete for the same screen space.
                  if (state.nearGeofenceEdge && state.warning == null)
                    const ProximityBanner(),
                  if (state.judgingQueue.isNotEmpty)
                    JudgingOverlay(entry: state.judgingQueue.first),
                  // Available in both dispersing and playing — the geofence
                  // rule already applies during dispersal (tick_punishments
                  // runs for both statuses), not just once a target's
                  // assigned. Hidden once dead: nothing left to navigate by.
                  if (geofence != null && state.phase is! IngameDead)
                    MyLocationButton(
                      geofence: geofence!,
                      selfPositionStream: selfPositionStream,
                    ),
                  if (state.myName case final myName?
                      when state.phase is! IngameDead)
                    SelfNameLabel(name: myName),
                  // The death screen has its own dedicated leave button in
                  // its content flow (#77) — this corner button covers the
                  // two phases before that, dispersing and playing (#78:
                  // "no mid-game quit" no longer blocks the living, it just
                  // makes leaving cost you the game).
                  if (state.phase is! IngameDead) const LeaveButton(),
                  // Nothing left to stay awake for once dead (#78) — no more
                  // compass pulses or warnings, and a pending frame_to_judge
                  // still wakes the device via its own push either way.
                  if (state.phase is! IngameDead)
                    WakeLockButton(keepAwake: state.keepAwake),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
