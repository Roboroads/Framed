import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/push/push_service.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/pinned_action_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import '../pre_join/pre_join_form.dart';
import 'host_setup_cubit.dart';
import 'host_setup_state.dart';
import '../../../../core/theme/spacing.dart';

/// Arbitrary fallback when GPS is unavailable/denied — Utrecht, NL (this
/// backend's home region).
const _fallbackCenter = LatLng(52.0907, 5.1214);

class HostSetupPage extends StatelessWidget {
  const HostSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HostSetupCubit(
        repository: getIt<LobbyRepository>(),
        session: getIt<GameSession>(),
        pushService: getIt<PushService>(),
      ),
      child: const _HostSetupView(),
    );
  }
}

class _HostSetupView extends StatefulWidget {
  const _HostSetupView();

  @override
  State<_HostSetupView> createState() => _HostSetupViewState();
}

class _HostSetupViewState extends State<_HostSetupView> {
  @override
  void initState() {
    super.initState();
    // Silent — game mode/play area/timing all default (GameSettings' own
    // defaults) and move to the lobby's "Game settings" screen, editable
    // after the game exists (#62). Only the GPS-derived center is still
    // needed upfront, since the server requires real coordinates to create
    // the game at all.
    currentLocationOrFallback(context, _fallbackCenter).then((center) {
      if (mounted) context.read<HostSetupCubit>().geofenceChanged(center);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.hostSetup.title)),
      body: BlocConsumer<HostSetupCubit, HostSetupState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == HostSetupStatus.success) {
            context.go('/lobby');
          } else if (state.status == HostSetupStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(state.error!))),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<HostSetupCubit>();
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
                    PreJoinForm(
                      name: state.name,
                      onNameChanged: cubit.nameChanged,
                      selfieBytes: state.selfieBytes,
                      onSelfieChanged: cubit.selfieChanged,
                    ),
                  ],
                ),
              ),
              PinnedActionBar(
                child: FilledButton(
                  onPressed: state.canSubmit ? cubit.submit : null,
                  child: state.status == HostSetupStatus.submitting
                      ? const ButtonSpinner()
                      : Text(t.hostSetup.createGame),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _errorMessage(LobbyError error) => switch (error) {
    LobbyError.badSettings => t.hostSetup.errorBadSettings,
    _ => t.hostSetup.errorGeneric,
  };
}
