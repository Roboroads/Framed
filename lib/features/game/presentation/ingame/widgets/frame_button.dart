import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/camera/in_app_camera_page.dart';
import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../frame_confirm_page.dart';
import '../ingame_bloc.dart';
import '../ingame_state.dart';
import 'countdown_text.dart';

/// The frame button (#21): ready to shoot, waiting on a verdict (held and
/// pending look identical by design — see #19), or cooling down from a
/// failed vote. The cooldown clock is the bloc's, not this widget's — it
/// just renders whatever `until` the server sent.
class FrameButton extends StatelessWidget {
  const FrameButton({required this.status, super.key});

  final IngameFrameStatus status;

  Future<void> _openCamera(BuildContext context) async {
    final bloc = context.read<IngameBloc>();
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) =>
            const InAppCameraPage(lensDirection: CameraLensDirection.back),
      ),
    );
    if (bytes == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FrameConfirmPage(photoBytes: bytes, bloc: bloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      FrameReady() => FilledButton.icon(
        onPressed: () => _openCamera(context),
        icon: const FramedIcons(FramedIcon.frame),
        label: Text(t.frame.button),
      ),
      FrameWaitingForVerdict() => FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty),
        label: Text(t.frame.waiting),
      ),
      FrameCooldown(:final until, :final reason) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (switch (reason) {
                'rejected' => t.frame.cooldownReasonRejected,
                'timeout' => t.frame.cooldownReasonTimeout,
                _ => null,
              }
              case final reasonText?) ...[
            Text(
              reasonText,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Gap.xs,
          ],
          CountdownText(
            deadline: until,
            builder: (context, time) => FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.timer_outlined),
              label: Text(t.frame.cooldown(time: time)),
            ),
          ),
        ],
      ),
    };
  }
}
