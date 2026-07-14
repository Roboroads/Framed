import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/widgets/geofence_map.dart';
import '../../../../core/widgets/geofence_map_viewer_page.dart';
import '../../../../i18n/strings.g.dart';
import 'lobby_bloc.dart';
import 'lobby_state.dart';

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
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.hostSetup.geofenceSectionTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _InfoIcon(message: t.hostSetup.geofenceInfo),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (lat == null || lng == null)
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
                Slider(
                  value: state.geofenceRadiusM.toDouble(),
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  label: t.hostSetup.geofenceRadiusLabel(
                    radius: state.geofenceRadiusM,
                  ),
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
              const Divider(height: 32),
              Text(
                t.hostSetup.timingSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _Stepper(
                label: t.hostSetup.disperseMinutes,
                info: t.hostSetup.disperseMinutesInfo,
                value: state.disperseMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeDisperseMinutes,
              ),
              _Stepper(
                label: t.hostSetup.softPunishmentMinutes,
                info: t.hostSetup.softPunishmentMinutesInfo,
                value: state.softPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeSoftPunishmentMinutes,
              ),
              _Stepper(
                label: t.hostSetup.hardPunishmentMinutes,
                info: t.hostSetup.hardPunishmentMinutesInfo,
                value: state.hardPunishmentMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeHardPunishmentMinutes,
              ),
              _Stepper(
                label: t.hostSetup.compassUpdateIntervalMinutes,
                info: t.hostSetup.compassUpdateIntervalMinutesInfo,
                value: state.compassUpdateIntervalMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeCompassUpdateIntervalMinutes,
              ),
              _Stepper(
                label: t.hostSetup.compassViewSeconds,
                info: t.hostSetup.compassViewSecondsInfo,
                value: state.compassViewSeconds,
                unit: t.hostSetup.unitSecondsShort,
                onChanged: bloc.changeCompassViewSeconds,
              ),
              _Stepper(
                label: t.hostSetup.voteTimeoutMinutes,
                info: t.hostSetup.voteTimeoutMinutesInfo,
                value: state.voteTimeoutMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeVoteTimeoutMinutes,
              ),
              _Stepper(
                label: t.hostSetup.frameCooldownMinutes,
                info: t.hostSetup.frameCooldownMinutesInfo,
                value: state.frameCooldownMinutes,
                unit: t.hostSetup.unitMinutesShort,
                onChanged: bloc.changeFrameCooldownMinutes,
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
      title: Row(
        children: [
          Expanded(child: Text(widget.label)),
          const SizedBox(width: 4),
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
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                suffixText: widget.unit,
              ),
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
