import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/chat/chat_limits.dart';
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
                          child: Text(switch (entry.cause) {
                            'mia' => t.finish.killChainMia(
                              victim: entry.victimName,
                            ),
                            'left' => t.finish.killChainLeft(
                              victim: entry.victimName,
                            ),
                            _ => t.finish.killChainFramed(
                              killer: entry.killerName ?? '?',
                              victim: entry.victimName,
                            ),
                          }),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        t.finish.chatTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 240,
                        child: _FinishChatPanel(chat: state.chat),
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

/// Post-game meetup chat (#79) — the same channel and history the death
/// screen's dead chat already used, just open to everyone here since the
/// game's over for good. Fixed-height panel with its own scroll, embedded
/// as one item in the finish screen's outer stats/kill-chain list.
class _FinishChatPanel extends StatefulWidget {
  const _FinishChatPanel({required this.chat});

  final List<FinishChatMessage> chat;

  @override
  State<_FinishChatPanel> createState() => _FinishChatPanelState();
}

class _FinishChatPanelState extends State<_FinishChatPanel> {
  final _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _composer.text;
    if (text.trim().isEmpty) return;
    context.read<FinishBloc>().sendChatMessage(text);
    _composer.clear();
  }

  @override
  Widget build(BuildContext context) {
    final myPlayerId = getIt<GameSession>().playerId;
    return Column(
      children: [
        Expanded(
          child: widget.chat.isEmpty
              ? Center(
                  child: Text(
                    t.finish.chatEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  itemCount: widget.chat.length,
                  itemBuilder: (context, i) {
                    final message = widget.chat[widget.chat.length - 1 - i];
                    return _FinishChatBubble(
                      message: message,
                      isMine: message.senderId == myPlayerId,
                    );
                  },
                ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _composer,
                decoration: InputDecoration(hintText: t.finish.chatHint),
                maxLength: maxChatMessageLength,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(context),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _send(context),
              tooltip: t.finish.chatSendButton,
            ),
          ],
        ),
      ],
    );
  }
}

class _FinishChatBubble extends StatelessWidget {
  const _FinishChatBubble({required this.message, required this.isMine});

  final FinishChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
