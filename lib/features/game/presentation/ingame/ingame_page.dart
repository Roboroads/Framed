import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_repository.dart';
import '../../domain/target.dart';
import 'ingame_bloc.dart';
import 'ingame_state.dart';

/// Lands here from the lobby (#10) on `dispersal_started`.
class IngamePage extends StatelessWidget {
  const IngamePage({required this.initialEndsAt, super.key});

  final DateTime initialEndsAt;

  @override
  Widget build(BuildContext context) {
    final session = getIt<GameSession>();
    return BlocProvider(
      create: (_) => IngameBloc(
        events: getIt<GameChannels>().player(session.playerId),
        crypto: session.crypto,
        repository: getIt<GameRepository>(),
        initialEndsAt: initialEndsAt,
      ),
      child: const _IngameView(),
    );
  }
}

class _IngameView extends StatelessWidget {
  const _IngameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<IngameBloc, IngameState>(
          builder: (context, state) => switch (state) {
            IngameDispersing(:final endsAt) => _DisperseCountdown(
              endsAt: endsAt,
            ),
            IngamePlaying(:final target) => _TargetCard(target: target),
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
  const _TargetCard({required this.target});

  final Target target;

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
          const SizedBox(height: 32),
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
