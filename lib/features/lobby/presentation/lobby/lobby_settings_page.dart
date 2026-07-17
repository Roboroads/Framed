import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/widgets/closable_dialog.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../i18n/strings.g.dart';
import 'lobby_bloc.dart';
import 'lobby_state.dart';
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
              _Stepper(
                label: t.hostSetup.disperseMinutes,
                info: t.hostSetup.disperseMinutesInfo,
                value: state.disperseMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) => bloc.changeSetting('disperse_minutes', v),
              ),
              _Stepper(
                label: t.hostSetup.softPunishmentMinutes,
                info: t.hostSetup.softPunishmentMinutesInfo,
                value: state.softPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('soft_punishment_minutes', v),
              ),
              _Stepper(
                label: t.hostSetup.hardPunishmentMinutes,
                info: t.hostSetup.hardPunishmentMinutesInfo,
                value: state.hardPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('hard_punishment_minutes', v),
              ),
              _Stepper(
                label: t.hostSetup.compassUpdateIntervalMinutes,
                info: t.hostSetup.compassUpdateIntervalMinutesInfo,
                value: state.compassUpdateIntervalMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) =>
                    bloc.changeSetting('compass_update_interval_minutes', v),
              ),
              _Stepper(
                label: t.hostSetup.compassViewSeconds,
                info: t.hostSetup.compassViewSecondsInfo,
                value: state.compassViewSeconds,
                unit: t.hostSetup.unitSecondsShort,
                onChanged: (v) => bloc.changeSetting('compass_view_seconds', v),
              ),
              _Stepper(
                label: t.hostSetup.voteTimeoutMinutes,
                info: t.hostSetup.voteTimeoutMinutesInfo,
                value: state.voteTimeoutMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: (v) => bloc.changeSetting('vote_timeout_minutes', v),
              ),
              _Stepper(
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

class _Stepper extends StatefulWidget {
  const _Stepper({
    required this.label,
    required this.info,
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  static const _min = 1;

  final String label;
  final String info;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  State<_Stepper> createState() => _StepperState();
}

class _StepperState extends State<_Stepper> {
  late final _controller = TextEditingController(text: '${widget.value}');
  late final _focusNode = FocusNode()..addListener(_onFocusChange);

  @override
  void didUpdateWidget(covariant _Stepper old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && !_focusNode.hasFocus) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final typed = int.tryParse(_controller.text);
    final clamped = (typed ?? widget.value) < _Stepper._min
        ? _Stepper._min
        : (typed ?? widget.value);
    if (clamped != widget.value) widget.onChanged(clamped);
    _controller.text = '$clamped';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          // Expanded, not Flexible: Flexible sizes to the text, so the icon
          // hugged the end of each label and landed at a different x on every
          // row. Expanded pushes it to a fixed right edge, so the column of
          // icons reads as a column.
          Expanded(child: Text(widget.label)),
          HGap.xs,
          _InfoIcon(message: widget.info),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: widget.value > _Stepper._min
                ? () => widget.onChanged(widget.value - 1)
                : null,
          ),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _focusNode.unfocus(),
              // A number, so the data face with tabular figures: these tick
              // between 1 and 2 digits as you press, and a proportional font
              // makes the field twitch on every step.
              style: AppTheme.mono(Theme.of(context).textTheme.bodyLarge!),
              // `border: InputBorder.none` alone isn't enough against a
              // global inputDecorationTheme: it clears `border` but leaves
              // the theme's fill and its 16px content padding, which squeeze
              // the number and its unit out of a 72px-wide field entirely.
              // collapsed drops both.
              //
              // The theme's outline survives (collapsed leaves the per-state
              // borders alone) and is left that way on purpose — it's the
              // only thing marking this as type-able rather than as a label
              // between two buttons.
              decoration: InputDecoration.collapsed(
                hintText: null,
              ).copyWith(isDense: true, suffixText: widget.unit),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => widget.onChanged(widget.value + 1),
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
        builder: (context) => ClosableDialog(child: Text(message)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.xs),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
