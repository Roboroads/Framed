import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/realtime/game_event.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import 'finish_bloc.dart';
import 'finish_state.dart';

/// Crowns the winner, shows stats and the kill chain, and offers the host
/// "replay with same players" (everyone else: "leave game") — issue #26,
/// IDEA.md "Screens" (game finish). Reached only via [GameEvent.gameFinished]
/// (from IngamePage's global listener, any ingame phase).
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
    return BlocProvider.value(value: _bloc, child: const _FinishView());
  }
}

class _FinishView extends StatelessWidget {
  const _FinishView();

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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        t.finish.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.youWon ? t.finish.youWon : _winnerLine(state),
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.finish.statDuration(
                          time: _formatDuration(state.durationSeconds),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      Text(
                        t.finish.statsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _StatLine(
                        label: t.finish.statMostKills,
                        names: _namesWithMax(state.stats, (s) => s.kills).$1,
                      ),
                      _StatLine(
                        label: t.finish.statMostMoved,
                        names: _namesWithMax(
                          state.stats,
                          (s) => s.distanceMovedM,
                        ).$1,
                      ),
                      _StatLine(
                        label: t.finish.statMostStill,
                        names: _namesWithMax(
                          state.stats,
                          (s) => s.stillSeconds,
                        ).$1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.finish.statCombinedMovement(
                          distance: state.totalDistanceMovedM
                              .round()
                              .toString(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.finish.killChainTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in state.killChain)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            entry.cause == 'mia'
                                ? t.finish.killChainMia(
                                    victim: entry.victimName,
                                  )
                                : t.finish.killChainFramed(
                                    killer: entry.killerName ?? '?',
                                    victim: entry.victimName,
                                  ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: state.isHost
                        ? FilledButton(
                            onPressed:
                                state.replayStatus == FinishReplayStatus.working
                                ? null
                                : () =>
                                      context.read<FinishBloc>().startReplay(),
                            child:
                                state.replayStatus == FinishReplayStatus.working
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(t.finish.replayButton),
                          )
                        : FilledButton(
                            onPressed: () => _confirmAndLeave(context),
                            child: Text(t.finish.leaveButton),
                          ),
                  ),
                ),
                if (state.replayStatus == FinishReplayStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      t.finish.replayError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
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
  Future<void> _confirmAndLeave(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: t.finish.leaveConfirmTitle,
      message: t.finish.leaveConfirmBody,
      confirmLabel: t.finish.leaveConfirmButton,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<FinishBloc>().leave();
    if (context.mounted) context.go('/');
  }

  String _winnerLine(FinishState state) {
    if (state.mode == 'most_frames') {
      final kills = state.stats
          .where((s) => s.playerId == state.winnerId)
          .map((s) => s.kills)
          .fold(0, (a, b) => a > b ? a : b);
      return t.finish.winnerFrames(name: state.winnerName, count: kills);
    }
    return t.finish.winnerLastManStanding(name: state.winnerName);
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  // Ties render together, not silently dropped — this returns every name
  // tied for the max, not just the first.
  (List<String>, num) _namesWithMax(
    List<FinishStat> stats,
    num Function(FinishStat) select,
  ) {
    if (stats.isEmpty) return (const [], 0);
    final max = stats.map(select).reduce((a, b) => a > b ? a : b);
    return (
      [
        for (final s in stats)
          if (select(s) == max) s.name,
      ],
      max,
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.names});

  final String label;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: ${names.join(', ')}'),
    );
  }
}
