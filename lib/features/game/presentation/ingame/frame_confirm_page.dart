import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/util/uuid.dart';
import '../../../../core/widgets/full_screen_photo_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/frame_error.dart';
import 'ingame_bloc.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Confirm/retake screen for a just-captured frame photo (#21).
///
/// [_frameUuid] is generated once and reused across retries of a failed
/// submit — the repository upserts to that same storage path, so a retry
/// after a dropped connection never orphans a partial upload (see #21's
/// storage policy note). Retaking the photo replaces this whole page
/// (a fresh capture gets a fresh uuid).
class FrameConfirmPage extends StatefulWidget {
  const FrameConfirmPage({
    required this.photoBytes,
    required this.bloc,
    super.key,
  });

  final Uint8List photoBytes;
  final IngameBloc bloc;

  @override
  State<FrameConfirmPage> createState() => _FrameConfirmPageState();
}

class _FrameConfirmPageState extends State<FrameConfirmPage> {
  final _frameUuid = generateUuidV4();
  bool _submitting = false;
  FrameError? _error;

  Future<void> _retake() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) =>
            const InAppCameraPage(lensDirection: CameraLensDirection.back),
      ),
    );
    if (bytes == null || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FrameConfirmPage(photoBytes: bytes, bloc: widget.bloc),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await widget.bloc.submitFrame(
      photoBytes: widget.photoBytes,
      frameUuid: _frameUuid,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  String _errorText(FrameError error) => switch (error) {
    FrameError.onCooldown => t.frame.errorOnCooldown,
    FrameError.frameAlreadyPending => t.frame.errorAlreadyPending,
    FrameError.wrongStatus => t.frame.errorWrongStatus,
    _ => t.frame.errorGeneric,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.frame.confirmTitle)),
      body: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    FullScreenPhotoPage.open(context, widget.photoBytes),
                child: ClipRRect(
                  borderRadius: AppTheme.corner,
                  child: Image.memory(widget.photoBytes, fit: BoxFit.cover),
                ),
              ),
            ),
            Gap.lg,
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.lg),
                child: Text(
                  _errorText(error),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : _retake,
                    child: Text(t.frame.retake),
                  ),
                ),
                HGap.lg,
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.frame.submit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
