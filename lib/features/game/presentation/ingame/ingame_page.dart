import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
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
    _bloc = IngameBloc(
      events: channels.player(session.playerId),
      crypto: session.crypto,
      repository: repository,
      initialEndsAt: widget.initialEndsAt,
    );
    // ponytail: two separate realtime subscriptions to player:{id} (one
    // here, one for _bloc's own `events` above) instead of sharing one
    // broadcast stream — simpler than plumbing a shared broadcast stream
    // through both consumers' lifecycles. Revisit if channel count matters.
    _locationService = LocationService(
      repository: repository,
      gameId: session.gameId,
      gameEvents: channels.game(session.gameId),
      playerEvents: channels.player(session.playerId),
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
