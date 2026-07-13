import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import '../pre_join/pre_join_form.dart';
import 'host_setup_cubit.dart';
import 'host_setup_state.dart';

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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t.hostSetup.modeSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioGroup<GameMode>(
                groupValue: state.mode,
                onChanged: (mode) => cubit.modeChanged(mode!),
                child: Column(
                  children: [
                    RadioListTile<GameMode>(
                      title: Text(t.hostSetup.modeMostFrames),
                      subtitle: Text(t.hostSetup.modeMostFramesDescription),
                      value: GameMode.mostFrames,
                    ),
                    RadioListTile<GameMode>(
                      title: Text(t.hostSetup.modeLastManStanding),
                      subtitle: Text(
                        t.hostSetup.modeLastManStandingDescription,
                      ),
                      value: GameMode.lastManStanding,
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Text(
                    t.hostSetup.geofenceSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 4),
                  _InfoIcon(message: t.hostSetup.geofenceInfo),
                ],
              ),
              const SizedBox(height: 8),
              if (state.geofenceCenter == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 240,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GeofenceMapViewerPage(
                            center: state.geofenceCenter!,
                            radiusM: state.geofenceRadiusM.toDouble(),
                          ),
                        ),
                      ),
                      child: AbsorbPointer(
                        child: GeofenceMap(
                          center: state.geofenceCenter!,
                          radiusM: state.geofenceRadiusM.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
                Slider(
                  value: state.geofenceRadiusM.toDouble(),
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  label: t.hostSetup.geofenceRadiusLabel(
                    radius: state.geofenceRadiusM,
                  ),
                  onChanged: (v) => cubit.geofenceRadiusChanged(v.round()),
                ),
              ],
              const Divider(height: 32),
              Text(
                t.hostSetup.timingSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _Stepper(
                label: t.hostSetup.disperseMinutes,
                info: t.hostSetup.disperseMinutesInfo,
                value: state.disperseMinutes,
                onChanged: cubit.disperseMinutesChanged,
              ),
              _Stepper(
                label: t.hostSetup.softPunishmentMinutes,
                info: t.hostSetup.softPunishmentMinutesInfo,
                value: state.softPunishmentMinutes,
                onChanged: cubit.softPunishmentMinutesChanged,
              ),
              _Stepper(
                label: t.hostSetup.hardPunishmentMinutes,
                info: t.hostSetup.hardPunishmentMinutesInfo,
                value: state.hardPunishmentMinutes,
                onChanged: cubit.hardPunishmentMinutesChanged,
              ),
              _Stepper(
                label: t.hostSetup.compassUpdateIntervalMinutes,
                info: t.hostSetup.compassUpdateIntervalMinutesInfo,
                value: state.compassUpdateIntervalMinutes,
                onChanged: cubit.compassUpdateIntervalMinutesChanged,
              ),
              _Stepper(
                label: t.hostSetup.compassViewSeconds,
                info: t.hostSetup.compassViewSecondsInfo,
                value: state.compassViewSeconds,
                onChanged: cubit.compassViewSecondsChanged,
              ),
              _Stepper(
                label: t.hostSetup.voteTimeoutMinutes,
                info: t.hostSetup.voteTimeoutMinutesInfo,
                value: state.voteTimeoutMinutes,
                onChanged: cubit.voteTimeoutMinutesChanged,
              ),
              _Stepper(
                label: t.hostSetup.frameCooldownMinutes,
                info: t.hostSetup.frameCooldownMinutesInfo,
                value: state.frameCooldownMinutes,
                onChanged: cubit.frameCooldownMinutesChanged,
              ),
              const Divider(height: 32),
              Text(
                t.preJoin.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              PreJoinForm(
                name: state.name,
                onNameChanged: cubit.nameChanged,
                selfieBytes: state.selfieBytes,
                onSelfieChanged: cubit.selfieChanged,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.canSubmit ? cubit.submit : null,
                child: state.status == HostSetupStatus.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.hostSetup.createGame),
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

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.info,
    required this.value,
    required this.onChanged,
  });

  static const _min = 1;

  final String label;
  final String info;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 4),
          _InfoIcon(message: info),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > _min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text('$value', textAlign: TextAlign.center),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => showDialog<void>(
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
                Text(message),
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
