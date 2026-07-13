import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/crypto/qr_payload.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import 'lobby_bloc.dart';
import 'lobby_state.dart';

/// The waiting room: live roster, settings, the join QR, and the start
/// button. Everything about this game — the id, this device's player id,
/// the game key — already lives in [GameSession] by the time either the
/// host flow (#8) or the join flow (#9) lands here.
class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<GameSession>();
    return BlocProvider(
      create: (_) => LobbyBloc(
        repository: getIt<LobbyRepository>(),
        session: session,
        events: getIt<GameChannels>().game(session.gameId),
        gameId: session.gameId,
      ),
      child: const _LobbyView(),
    );
  }
}

class _LobbyView extends StatelessWidget {
  const _LobbyView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        try {
          await context.read<LobbyBloc>().leave();
        } catch (_) {
          // Best-effort: the player still wants out even if the network
          // call failed. The game/lobby cleans up stale players anyway.
        }
        if (context.mounted) context.go('/');
      },
      child: BlocConsumer<LobbyBloc, LobbyState>(
        listenWhen: (previous, current) =>
            previous.dispersalEndsAt != current.dispersalEndsAt ||
            (previous.starting && !current.starting && current.error != null),
        listener: (context, state) {
          final endsAt = state.dispersalEndsAt;
          if (endsAt != null) {
            context.go('/location-gate', extra: endsAt);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(state.error!))),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(t.lobby.title)),
            body: switch (state.phase) {
              LobbyPhase.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              LobbyPhase.error => Center(
                child: Text(_errorMessage(state.error ?? LobbyError.unknown)),
              ),
              LobbyPhase.ready => _LobbyBody(state: state),
            },
          );
        },
      ),
    );
  }

  String _errorMessage(LobbyError error) => switch (error) {
    LobbyError.tooFewPlayers => t.lobby.startTooFewPlayers,
    _ => t.lobby.errorGeneric,
  };
}

class _LobbyBody extends StatefulWidget {
  const _LobbyBody({required this.state});

  final LobbyState state;

  @override
  State<_LobbyBody> createState() => _LobbyBodyState();
}

class _LobbyBodyState extends State<_LobbyBody> {
  // Auto-shown once when the join token first becomes available (i.e. when
  // the host opens the lobby) — a flag rather than tying this to a specific
  // lifecycle callback, since `joinToken` arrives asynchronously via bloc
  // state, not necessarily on the first build.
  bool _qrDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LobbyBloc>();
    final state = widget.state;
    final joinToken = state.joinToken;
    if (!_qrDialogShown && bloc.isHost && joinToken != null) {
      _qrDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showQrDialog(context, joinToken);
      });
    }
    return Column(
      children: [
        _ModeBanner(
          mode: state.mode,
          isHost: bloc.isHost,
          onChangeMode: bloc.changeMode,
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              for (final player in state.roster)
                _RosterTile(
                  player: player,
                  isHost: player.id == state.hostPlayerId,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: bloc.isHost
              ? Column(
                  children: [
                    if (joinToken != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _showQrDialog(context, joinToken),
                          icon: const Icon(Icons.qr_code),
                          label: Text(t.lobby.showQrButton),
                        ),
                      ),
                    Text(
                      t.lobby.readyCount(
                        ready: state.readyCount,
                        total: state.roster.length,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: state.canStart ? bloc.start : null,
                      child: state.starting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.lobby.startButton),
                    ),
                  ],
                )
              : Text(t.lobby.waitingForHost),
        ),
      ],
    );
  }

  void _showQrDialog(BuildContext context, String joinToken) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              _JoinQr(joinToken: joinToken),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({
    required this.mode,
    required this.isHost,
    required this.onChangeMode,
  });

  final GameMode mode;
  final bool isHost;
  final ValueChanged<GameMode> onChangeMode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title(mode), style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(_description(mode)),
      trailing: isHost ? const Icon(Icons.edit_outlined) : null,
      onTap: isHost ? () => _showModePicker(context) : null,
    );
  }

  String _title(GameMode mode) => switch (mode) {
    GameMode.mostFrames => t.hostSetup.modeMostFrames,
    GameMode.lastManStanding => t.hostSetup.modeLastManStanding,
  };

  String _description(GameMode mode) => switch (mode) {
    GameMode.mostFrames => t.hostSetup.modeMostFramesDescription,
    GameMode.lastManStanding => t.hostSetup.modeLastManStandingDescription,
  };

  Future<void> _showModePicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<GameMode>(
          groupValue: mode,
          onChanged: (value) {
            Navigator.of(sheetContext).pop();
            if (value != null) onChangeMode(value);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.lobby.changeMode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RadioListTile<GameMode>(
                title: Text(t.hostSetup.modeMostFrames),
                subtitle: Text(t.hostSetup.modeMostFramesDescription),
                value: GameMode.mostFrames,
              ),
              RadioListTile<GameMode>(
                title: Text(t.hostSetup.modeLastManStanding),
                subtitle: Text(t.hostSetup.modeLastManStandingDescription),
                value: GameMode.lastManStanding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.player, required this.isHost});

  final LobbyPlayer player;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        player.hasSelfie ? Icons.check_circle : Icons.hourglass_empty,
      ),
      title: Text(player.name),
      trailing: isHost
          ? Chip(label: Text(t.lobby.hostBadge))
          : Text(player.hasSelfie ? t.lobby.readyBadge : t.lobby.notReadyBadge),
    );
  }
}

class _JoinQr extends StatefulWidget {
  const _JoinQr({required this.joinToken});

  final String joinToken;

  @override
  State<_JoinQr> createState() => _JoinQrState();
}

class _JoinQrState extends State<_JoinQr> {
  // Fetched once — a FutureBuilder built directly in build() would restart
  // from "waiting" (a visible flicker) on every parent rebuild (e.g. a
  // roster change), since `.keyBytes` returns a fresh Future each call.
  late final _keyBytes = getIt<GameSession>().crypto.keyBytes;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _keyBytes,
      builder: (context, snapshot) {
        final keyBytes = snapshot.data;
        if (keyBytes == null) return const SizedBox(height: 24);
        final payload = QrPayload(
          joinToken: widget.joinToken,
          keyBytes: keyBytes,
        );
        // Debug-only: lets a driving tool (adb, flutter-mcp-toolkit) read
        // the join link straight from the log instead of scanning the QR,
        // for multi-device testing. Stripped in release builds (assert).
        assert(() {
          // ignore: avoid_print
          print('QR_PAYLOAD_DEBUG: ${payload.encode()}');
          return true;
        }());
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                t.lobby.scanToJoin,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: QrImageView(
                  data: payload.encode(),
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
