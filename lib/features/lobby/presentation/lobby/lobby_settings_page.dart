import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../i18n/strings.g.dart';
import 'lobby_bloc.dart';
import 'lobby_state.dart';
import 'setting_stepper.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Play area (radius only — the center always tracks GPS, #43) and timing,
/// editable in the lobby instead of upfront in host setup (#62). Game mode
/// stays on [LobbyPage]'s own `_ModeBanner`, which already covers it.
class LobbySettingsPage extends StatelessWidget {
  const LobbySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LobbyBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(t.lobby.gameSettingsButton)),
      body: BlocBuilder<LobbyBloc, LobbyState>(
        builder: (context, state) {
          final lat = state.geofenceLat;
          final lng = state.geofenceLng;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.lg,
              Space.xl,
              Space.xl,
            ),
            children: [
              SectionHeader(t.hostSetup.geofenceSectionTitle),
              // Shown, not hidden behind an info icon. It's one sentence and
              // it's the rule the server will kill you over — the seven
              // timing knobs below keep their [i] because their explanations
              // are paragraphs, not because hiding things is the house style.
              Text(
                t.hostSetup.geofenceInfo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Gap.md,
              if (lat == null || lng == null)
                const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                ClipRRect(
                  borderRadius: AppTheme.corner,
                  child: SizedBox(
                    height: 240,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GeofenceMapViewerPage(
                            center: LatLng(lat, lng),
                            radiusM: state.geofenceRadiusM.toDouble(),
                          ),
                        ),
                      ),
                      child: AbsorbPointer(
                        child: GeofenceMap(
                          center: LatLng(lat, lng),
                          radiusM: state.geofenceRadiusM.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap.md,
                // The radius, stated. It used to live only in the slider's
                // drag tooltip, so the host could see the circle and the
                // handle but never the number unless they were mid-drag —
                // and "how big is the play area" is the one question this
                // screen exists to answer.
                //
                // Mono at title size, not a display role: the display sizes
                // are for numbers that *are* the screen (a dispersal clock
                // filling the view). This one labels the slider under it, and
                // at 30px it shouted over the map it describes.
                Center(
                  child: Text(
                    t.hostSetup.geofenceRadiusLabel(
                      radius: state.geofenceRadiusM,
                    ),
                    style: AppTheme.mono(
                      Theme.of(context).textTheme.titleLarge!,
                    ),
                  ),
                ),
                Slider(
                  value: state.geofenceRadiusM.toDouble(),
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  onChanged: (v) => bloc.changeGeofenceRadius(v.round()),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final fallback = LatLng(lat, lng);
                      final center = await currentLocationOrFallback(
                        context,
                        fallback,
                      );
                      if (center != fallback) {
                        await bloc.changeGeofenceCenter(center);
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: Text(t.hostSetup.recenterButton),
                  ),
                ),
              ],
              Gap.xl,
              SectionHeader(t.hostSetup.timingSectionTitle),
              SettingStepper(
                label: t.hostSetup.disperseMinutes,
                info: t.hostSetup.disperseMinutesInfo,
                value: state.disperseMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) => bloc.changeSetting('disperse_minutes', v),
              ),
              SettingStepper(
                label: t.hostSetup.softPunishmentMinutes,
                info: t.hostSetup.softPunishmentMinutesInfo,
                value: state.softPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('soft_punishment_minutes', v),
              ),
              SettingStepper(
                label: t.hostSetup.hardPunishmentMinutes,
                info: t.hostSetup.hardPunishmentMinutesInfo,
                value: state.hardPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('hard_punishment_minutes', v),
              ),
              SettingStepper(
                label: t.hostSetup.compassUpdateIntervalMinutes,
                info: t.hostSetup.compassUpdateIntervalMinutesInfo,
                value: state.compassUpdateIntervalMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('compass_update_interval_minutes', v),
              ),
              SettingStepper(
                label: t.hostSetup.compassViewSeconds,
                info: t.hostSetup.compassViewSecondsInfo,
                value: state.compassViewSeconds,
                unit: t.hostSetup.unitSecondsShort,
                onChanged: (v) => bloc.changeSetting('compass_view_seconds', v),
              ),
              SettingStepper(
                label: t.hostSetup.voteTimeoutMinutes,
                info: t.hostSetup.voteTimeoutMinutesInfo,
                value: state.voteTimeoutMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) => bloc.changeSetting('vote_timeout_minutes', v),
              ),
              SettingStepper(
                label: t.hostSetup.frameCooldownMinutes,
                info: t.hostSetup.frameCooldownMinutesInfo,
                value: state.frameCooldownMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('frame_cooldown_minutes', v),
              ),
              Gap.xl,
              // Danger-styled confirmation: reset isn't irreversible, but it
              // throws away everything the host has tuned, so it asks first.
              // The button is a plain text button, not filled — it's an
              // escape hatch, not the screen's main action.
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final ok = await showConfirmationDialog(
                      context: context,
                      title: t.hostSetup.resetConfirmTitle,
                      message: t.hostSetup.resetConfirmBody,
                      confirmLabel: t.hostSetup.resetConfirmButton,
                    );
                    if (ok) await bloc.resetSettings();
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: Text(t.hostSetup.resetButton),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).extension<GameColors>()!.danger,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
