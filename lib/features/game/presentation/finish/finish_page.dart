import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/chat/chat_panel.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/framed_icons.dart';
import '../../../../core/theme/motion.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/util/duration_format.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/pinned_action_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../ingame/widgets/reticle_frame.dart';
import 'finish_bloc.dart';
import 'finish_state.dart';

/// Crowns the winner, shows stats and the kill chain, and offers the host
/// "replay with same players" (everyone else: "leave game") — issue #26,
/// IDEA.md "Screens" (game finish). Reached only via [GameEvent.gameFinished]
/// (from IngamePage's global listener, any ingame phase).
///
/// The hierarchy is YOUR verdict, not a neutral scoreboard (#108): winning
/// puts your result in the reticle, losing crowns the winner there instead.
/// A dead winner in *most frames wins* is a legitimate outcome (IDEA.md
/// "Game rules") and gets said out loud rather than left looking like a bug.
class FinishPage extends StatefulWidget {
  const FinishPage({required this.event, super.key});

  final GameFinished event;

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  late final FinishBloc _bloc;

  @override
  void initState() {
    super.initState();
    final session = getIt<GameSession>();
    _bloc = FinishBloc(
      initialEvent: widget.event,
      gameEvents: getIt<GameChannels>().game(session.gameId),
      deadChatEvents: getIt<GameChannels>().deadChat(session.gameId),
      crypto: session.crypto,
      repository: getIt<GameRepository>(),
      session: session,
      gameId: session.gameId,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _bloc, child: const FinishView());
  }
}

/// Public (unlike most page views) so widget tests and harnesses can mount
/// it against a stub [FinishBloc] without the page's DI wiring.
class FinishView extends StatelessWidget {
  const FinishView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<FinishBloc, FinishState>(
          listenWhen: (previous, current) =>
              previous.replayReadyGameId != current.replayReadyGameId &&
              current.replayReadyGameId != null,
          listener: (context, state) => context.go('/lobby'),
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final theme = Theme.of(context);
            final session = getIt<GameSession>();
            // isActive guard: leave() ends the session before the exit
            // transition finishes, and a late chat message can rebuild
            // this view in that window — the bare getter would throw.
            final myPlayerId = session.isActive ? session.playerId : '';
            // Players who walked out keep their stats server-side, but the
            // min-players fallback only crowns among those who stayed —
            // leaving a quit player atop "Most kills" would contradict the
            // winner two inches above it. Out of contention for that row.
            final leaverNames = {
              for (final e in state.killChain)
                if (e.cause == 'left') e.victimName,
            };
            final killContenders = [
              for (final s in state.stats)
                if (!leaverNames.contains(s.name)) s,
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                    children: [
                      Gap.xl,
                      _VerdictHero(state: state, myPlayerId: myPlayerId),
                      Gap.xxl,
                      Text(
                        t.finish.statsTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      Gap.sm,
                      _StatRow(
                        label: t.finish.statMostKills,
                        names: _namesWithMax(killContenders, (s) => s.kills),
                        value: _maxOf(
                          killContenders,
                          (s) => s.kills,
                        ).round().toString(),
                      ),
                      _StatRow(
                        label: t.finish.statMostMoved,
                        names: _namesWithMax(
                          state.stats,
                          (s) => s.distanceMovedM,
                        ),
                        value: formatMeters(
                          _maxOf(
                            state.stats,
                            (s) => s.distanceMovedM,
                          ).toDouble(),
                        ),
                      ),
                      _StatRow(
                        label: t.finish.statMostStill,
                        names: _namesWithMax(
                          state.stats,
                          (s) => s.stillSeconds,
                        ),
                        // "12m" alone would collide with the meter values
                        // above it — the suffix says which m this is.
                        value: t.finish.stillValue(
                          time: formatDuration(
                            _maxOf(state.stats, (s) => s.stillSeconds).round(),
                          ),
                        ),
                      ),
                      _StatRow(
                        label: t.finish.statCombinedLabel,
                        names: const [],
                        value: formatMeters(state.totalDistanceMovedM),
                      ),
                      Gap.xl,
                      Text(
                        t.finish.killChainTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      Gap.sm,
                      _KillChain(entries: state.killChain),
                      Gap.xl,
                      Text(
                        t.finish.chatTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      Gap.sm,
                      SizedBox(
                        height: 240,
                        child: ChatPanel(
                          chat: state.chat,
                          myPlayerId: myPlayerId,
                          onSend: (text) =>
                              context.read<FinishBloc>().sendChatMessage(text),
                          emptyText: t.finish.chatEmpty,
                          hintText: t.finish.chatHint,
                          sendTooltip: t.finish.chatSendButton,
                        ),
                      ),
                      Gap.lg,
                    ],
                  ),
                ),
                PinnedActionBar(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.replayStatus == FinishReplayStatus.error)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Space.sm),
                          child: Text(
                            t.finish.replayError,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      state.isHost
                          ? FilledButton(
                              onPressed:
                                  state.replayStatus ==
                                      FinishReplayStatus.working
                                  ? null
                                  : () => context
                                        .read<FinishBloc>()
                                        .startReplay(),
                              child:
                                  state.replayStatus ==
                                      FinishReplayStatus.working
                                  ? const ButtonSpinner()
                                  : Text(t.finish.replayButton),
                            )
                          : FilledButton(
                              onPressed: () => _confirmAndLeave(context),
                              child: Text(t.finish.leaveButton),
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // The button already fired without confirmation before #77.
  Future<void> _confirmAndLeave(BuildContext context) => confirmAndLeave(
    context: context,
    title: t.finish.leaveConfirmTitle,
    message: t.finish.leaveConfirmBody,
    confirmLabel: t.finish.leaveConfirmButton,
    onConfirmed: (context) => context.read<FinishBloc>().leave(),
  );

  num _maxOf(List<FinishStat> stats, num Function(FinishStat) select) {
    if (stats.isEmpty) return 0;
    return stats.map(select).reduce((a, b) => a > b ? a : b);
  }

  // Ties render together, not silently dropped — this returns every name
  // tied for the max, not just the first.
  List<String> _namesWithMax(
    List<FinishStat> stats,
    num Function(FinishStat) select,
  ) {
    if (stats.isEmpty) return const [];
    final max = stats.map(select).reduce((a, b) => a > b ? a : b);
    return [
      for (final s in stats)
        if (select(s) == max) s.name,
    ];
  }
}

/// Switches to km past 1000 — a finish stat is a trophy figure, not a
/// navigation readout. The km string takes whole and tenth separately so
/// the decimal separator lives in each locale's translation.
String formatMeters(double meters) {
  if (meters >= 1000) {
    final tenths = (meters / 100).round();
    return t.finish.kmValue(
      whole: (tenths ~/ 10).toString(),
      tenth: (tenths % 10).toString(),
    );
  }
  return t.finish.metersValue(n: meters.round().toString());
}

/// The adaptive verdict (#108): "You won!" in the reticle when you won,
/// the winner crowned in it when you didn't. Dead winners are named as
/// deliberate; the tie-break (survival time among tied frame counts) is
/// the server's call and this widget just renders whoever it crowned.
class _VerdictHero extends StatelessWidget {
  const _VerdictHero({required this.state, required this.myPlayerId});

  final FinishState state;
  final String myPlayerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dead = theme.extension<GameColors>()!.dead;

    // The kill chain is the only record of deaths here — stats carry no
    // alive flag. Names, not ids: that's what the server publishes.
    final deadNames = {for (final e in state.killChain) e.victimName};
    final myStat = state.stats
        .where((s) => s.playerId == myPlayerId)
        .firstOrNull;
    final iDied = myStat != null && deadNames.contains(myStat.name);
    final winnerDied = deadNames.contains(state.winnerName);
    final winnerKills = state.stats
        .where((s) => s.playerId == state.winnerId)
        .map((s) => s.kills)
        .fold(0, (a, b) => a > b ? a : b);
    // A dead winner exists in last-man games too: the min-players fallback
    // crowns the frames leader when a game collapses below three players
    // (IDEA.md "Game rules"). Whenever the winner is in the kill chain, the
    // win WAS by frames — present it that way, whatever the configured
    // mode, instead of calling a dead player "last one standing".
    final framesWin = state.mode == 'most_frames' || winnerDied;

    final bigNumber = framesWin
        ? winnerKills.toString()
        : formatDuration(state.durationSeconds);
    final caption = framesWin
        ? t.finish.framesCaption(n: winnerKills)
        : t.finish.lastOneStanding;

    return _LockOn(
      child: Column(
        children: [
          Text(
            t.finish.title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap.md,
          ReticleFrame(
            color: state.youWon
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            arm: 20,
            inset: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.xxl,
                vertical: Space.xl,
              ),
              child: Column(
                children: [
                  if (!state.youWon) ...[
                    Text(
                      t.finish.winnerEyebrow,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Gap.xs,
                  ],
                  Text(
                    state.youWon ? t.finish.youWon : state.winnerName,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Gap.md,
                  Text(
                    bigNumber,
                    style: AppTheme.mono(theme.textTheme.displayMedium!),
                  ),
                  Text(
                    caption,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // A dead winner is the rules working, not a glitch — say so in
          // the dead color, with the frame mark it was earned with. The
          // copy stays cause-neutral ("out", not "framed"): the chain can
          // also end a winner via MIA or the min-players fallback.
          if (framesWin && (state.youWon ? iDied : winnerDied)) ...[
            Gap.lg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FramedIcons(FramedIcon.frame, size: 16, color: dead),
                HGap.sm,
                Flexible(
                  child: Text(
                    state.youWon
                        ? t.finish.wonWhileDead
                        : t.finish.winnerDied(name: state.winnerName),
                    style: theme.textTheme.bodyMedium?.copyWith(color: dead),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
          if (!state.youWon && myStat != null) ...[
            Gap.lg,
            Text(
              t.finish.yourResult(n: myStat.kills),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Skipped when the hero's big number IS the duration — the same
          // figure twice in a row reads as a bug.
          if (framesWin) ...[
            Gap.md,
            Text(
              t.finish.statDuration(
                time: formatDuration(state.durationSeconds),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One-shot entrance: the verdict settles into focus, brackets closing in
/// slightly — the same capture gesture as the app's screen transitions.
class _LockOn extends StatelessWidget {
  const _LockOn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.gate(context, Motion.lock),
      curve: Motion.enter,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 1.06 - 0.06 * value, child: child),
      ),
    );
  }
}

/// One "who leads what" line: label and name(s) left, the figure right in
/// mono — numbers are instrument readouts (#105).
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.names,
    required this.value,
  });

  final String label;
  final List<String> names;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (names.isNotEmpty)
                  Text(names.join(', '), style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          HGap.lg,
          Text(value, style: AppTheme.mono(theme.textTheme.titleMedium!)),
        ],
      ),
    );
  }
}

/// The game's story in death order, off the server's kill_chain verbatim.
/// Icon plus text per entry — the icon color is never the only signal.
class _KillChain extends StatelessWidget {
  const _KillChain({required this.entries});

  final List<FinishKillChainEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = theme.extension<GameColors>()!;
    return Container(
      padding: const EdgeInsets.only(left: Space.md),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  switch (entry.cause) {
                    'mia' => FramedIcons(
                      FramedIcon.warning,
                      size: 16,
                      color: game.warning,
                    ),
                    'left' => Icon(Icons.logout, size: 16, color: game.dead),
                    _ => FramedIcons(
                      FramedIcon.frame,
                      size: 16,
                      color: game.danger,
                    ),
                  },
                  HGap.sm,
                  Expanded(
                    child: Text(switch (entry.cause) {
                      'mia' => t.finish.killChainMia(victim: entry.victimName),
                      'left' => t.finish.killChainLeft(
                        victim: entry.victimName,
                      ),
                      _ => t.finish.killChainFramed(
                        killer: entry.killerName ?? '?',
                        victim: entry.victimName,
                      ),
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
