import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/crypto/qr_payload.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/realtime/game_channels.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/pinned_action_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import 'lobby_bloc.dart';
import 'lobby_settings_page.dart';
import 'lobby_state.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_theme.dart';

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
        await _confirmAndLeave(context);
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
            appBar: AppBar(
              title: Text(t.lobby.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: t.lobby.leaveButton,
                  onPressed: () => _confirmAndLeave(context),
                ),
              ],
            ),
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

  // Shared by the back gesture and the AppBar button (#77) — leaving used
  // to be silent and accidental (a bare back-gesture PopScope with no
  // confirmation, no visible button).
  Future<void> _confirmAndLeave(BuildContext context) => confirmAndLeave(
    context: context,
    title: t.lobby.leaveConfirmTitle,
    message: t.lobby.leaveConfirmBody,
    confirmLabel: t.lobby.leaveConfirmButton,
    onConfirmed: (context) async {
      try {
        await context.read<LobbyBloc>().leave();
      } catch (_) {
        // Best-effort: the player still wants out even if the network
        // call failed. The game/lobby cleans up stale players anyway.
      }
    },
  );
}

/// The lobby's job changes as it fills, and the layout says so.
///
/// For a host standing alone, the only thing that matters is getting people
/// in, so the join code leads. It used to be a dialog fired from the first
/// build, which put the one irreplaceable thing on the screen behind a modal
/// the host had to dismiss to see anything and hunt for a button to get back.
/// Now it's the first thing under the bar, and the roster grows underneath it.
class _LobbyBody extends StatelessWidget {
  const _LobbyBody({required this.state});

  final LobbyState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LobbyBloc>();
    final joinToken = state.joinToken;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.lg,
              Space.xl,
              Space.xl,
            ),
            children: [
              if (bloc.isHost && joinToken != null) ...[
                SectionHeader(t.lobby.joinSectionTitle),
                // The code stays up for the whole lobby, however full it
                // gets. Every player joins by scanning it, so in a ten-
                // player game the host is still holding it out for the
                // tenth — hiding it once the *first* person arrives would
                // take it away exactly when nine people still need it, and
                // take the note about the key with it. There's no expected
                // headcount to know when everyone's in, so the app doesn't
                // guess.
                _JoinHandover(joinToken: joinToken),
                Gap.xl,
              ],
              SectionHeader(t.lobby.modeSectionTitle),
              _ModeBanner(
                mode: state.mode,
                isHost: bloc.isHost,
                onChangeMode: bloc.changeMode,
              ),
              Gap.xl,
              if (state.geofenceLat != null && state.geofenceLng != null) ...[
                SectionHeader(t.lobby.playAreaSectionTitle),
                _GeofencePreview(
                  center: LatLng(state.geofenceLat!, state.geofenceLng!),
                  radiusM: state.geofenceRadiusM.toDouble(),
                ),
                Gap.xl,
              ],
              SectionHeader(
                t.lobby.rosterSectionTitle,
                // A count is a number, so it's mono and tabular — it ticks
                // up while you watch it, and the label shouldn't jitter.
                trailing: Text(
                  t.lobby.readyCount(
                    ready: state.readyCount,
                    total: state.roster.length,
                  ),
                  style: AppTheme.mono(Theme.of(context).textTheme.bodySmall!),
                ),
              ),
              for (final player in state.roster)
                _RosterTile(
                  player: player,
                  isHost: player.id == state.hostPlayerId,
                ),
              if (state.roster.length == 1 && bloc.isHost) ...[
                Gap.md,
                Text(
                  t.lobby.waitingForPlayers,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        _LobbyActions(state: state),
      ],
    );
  }
}

/// The host's controls, pinned below the scroll: whatever the roster is
/// doing, "start" and "settings" stay where the thumb left them.
class _LobbyActions extends StatelessWidget {
  const _LobbyActions({required this.state});

  final LobbyState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LobbyBloc>();
    final theme = Theme.of(context);

    if (!bloc.isHost) {
      return Padding(
        padding: Insets.screen,
        child: Text(
          t.lobby.waitingForHost,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return PinnedActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider<LobbyBloc>.value(
                  value: bloc,
                  child: const LobbySettingsPage(),
                ),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
            label: Text(t.lobby.gameSettingsButton),
          ),
          Gap.sm,
          FilledButton(
            onPressed: state.canStart ? bloc.start : null,
            child: state.starting
                ? const ButtonSpinner()
                : Text(t.lobby.startButton),
          ),
        ],
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
    final theme = Theme.of(context);
    // Only the host can change this, so only the host gets the affordance —
    // a tappable-looking row a guest can't tap is worse than a plain one.
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title(mode), style: theme.textTheme.headlineSmall),
              Gap.xs,
              Text(
                _description(mode),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isHost) ...[
          HGap.md,
          Icon(Icons.edit_outlined, color: theme.colorScheme.onSurfaceVariant),
        ],
      ],
    );

    if (!isHost) return row;
    return InkWell(
      onTap: () => _showModePicker(context),
      borderRadius: AppTheme.corner,
      child: Padding(padding: const EdgeInsets.all(Space.sm), child: row),
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
                padding: const EdgeInsets.all(Space.lg),
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

/// The play area, visible to every player waiting in the lobby, not just
/// the host — before #71 nobody but the host could see the boundary until
/// the game actually started. Tapping it opens the same full-screen,
/// pannable viewer the host's "Game settings" screen uses.
class _GeofencePreview extends StatelessWidget {
  const _GeofencePreview({required this.center, required this.radiusM});

  final LatLng center;
  final double radiusM;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: AppTheme.corner,
        child: SizedBox(
          height: 160,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    GeofenceMapViewerPage(center: center, radiusM: radiusM),
              ),
            ),
            child: AbsorbPointer(
              child: GeofenceMap(center: center, radiusM: radiusM),
            ),
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
    final theme = Theme.of(context);
    final game = theme.extension<GameColors>()!;
    final ready = player.hasSelfie;
    // Ready-ness carries an icon *and* a word, never just the colour — a
    // player who can't tell green from grey still has two other signals.
    final colour = ready ? game.alive : game.dead;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle : Icons.hourglass_empty,
            size: 20,
            color: colour,
          ),
          HGap.md,
          Expanded(child: Text(player.name, style: theme.textTheme.bodyLarge)),
          if (isHost) ...[
            Chip(
              label: Text(t.lobby.hostBadge),
              visualDensity: VisualDensity.compact,
            ),
            HGap.sm,
          ],
          Text(
            ready ? t.lobby.readyBadge : t.lobby.notReadyBadge,
            style: theme.textTheme.labelMedium?.copyWith(color: colour),
          ),
        ],
      ),
    );
  }
}

/// The handover. Everything else in this app is replaceable; this isn't.
///
/// The game key is generated on the host's phone and travels only inside this
/// code (CLAUDE.md: never send the key to the server). That makes this the one
/// screen where the app is holding something it can't get back — so it says
/// so, rather than leaving the host to assume we have a copy.
class _JoinHandover extends StatefulWidget {
  const _JoinHandover({required this.joinToken});

  final String joinToken;

  @override
  State<_JoinHandover> createState() => _JoinHandoverState();
}

class _JoinHandoverState extends State<_JoinHandover> {
  // Fetched once — a FutureBuilder built directly in build() would restart
  // from "waiting" (a visible flicker) on every parent rebuild (e.g. a
  // roster change), since `.keyBytes` returns a fresh Future each call.
  late final _keyBytes = getIt<GameSession>().crypto.keyBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Uint8List>(
      future: _keyBytes,
      builder: (context, snapshot) {
        final keyBytes = snapshot.data;
        if (keyBytes == null) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
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

        void openFullScreen() => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _FullScreenQr(payload: payload),
          ),
        );
        final share = OutlinedButton.icon(
          onPressed: () =>
              SharePlus.instance.share(ShareParams(text: payload.encode())),
          icon: const Icon(Icons.share_outlined),
          label: Text(t.lobby.shareLinkButton),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QrCard(payload: payload, onTap: openFullScreen),
            Gap.md,
            Text(
              t.lobby.keyLivesHere,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Gap.md,
            share,
          ],
        );
      },
    );
  }
}

/// The code itself, on white because a scanner needs the contrast.
class _QrCard extends StatelessWidget {
  const _QrCard({required this.payload, required this.onTap});

  final QrPayload payload;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: t.lobby.scanToJoin,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.corner,
        child: Container(
          padding: const EdgeInsets.all(Space.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppTheme.corner,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              // Colors.white, not a scheme role, and not themed: a QR reader
              // needs a bright quiet zone and dark modules. In dark mode a
              // surface-coloured code is unscannable, which would break the
              // one thing this screen exists to do.
              Container(
                padding: const EdgeInsets.all(Space.md),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.corner,
                ),
                child: QrImageView(
                  data: payload.encode(),
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              Gap.md,
              Text(
                t.lobby.tapQrToEnlarge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The code, as big as the glass allows.
///
/// Scanning happens across a pub table in bad light, on someone else's older
/// phone camera. Size is the whole job here, so this screen is nothing but
/// code — and it forces the backlight up by filling the screen with white.
class _FullScreenQr extends StatelessWidget {
  const _FullScreenQr({required this.payload});

  final QrPayload payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(t.lobby.scanToJoin),
      ),
      body: Center(
        child: Padding(
          padding: Insets.screen,
          child: QrImageView(
            data: payload.encode(),
            version: QrVersions.auto,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
