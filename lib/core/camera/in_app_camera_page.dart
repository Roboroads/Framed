import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../i18n/strings.g.dart';
import '../theme/framed_icons.dart';
import '../widgets/permission_rationale.dart';

enum _Status { initializing, ready, permissionDenied, error }

/// Some emulator camera backends never produce a first frame — initialize()
/// then hangs forever with no exception. A real camera opens in well under
/// this on any device that actually works.
const _initTimeout = Duration(seconds: 10);

/// Full-screen in-app photo capture (front camera by default). Pops with the
/// captured bytes, or `null` if the user backs out.
///
/// Shared by the pre-join selfie step (#8/#9) and the ingame frame camera
/// (#21) — one wrapper, so both get the same permission-recovery behavior.
class InAppCameraPage extends StatefulWidget {
  const InAppCameraPage({
    this.lensDirection = CameraLensDirection.front,
    super.key,
  });

  final CameraLensDirection lensDirection;

  @override
  State<InAppCameraPage> createState() => _InAppCameraPageState();
}

class _InAppCameraPageState extends State<InAppCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _Status _status = _Status.initializing;

  // Set alongside _Status.permissionDenied (#85): "don't ask again" means
  // _initialize()'s own retry can never succeed, only Settings can — same
  // distinction PermissionGate and BackgroundLocationGate already make.
  bool _permanentlyDenied = false;

  // Bumped on every dispose/backgrounding so a slow in-flight _initialize()
  // can tell it's been superseded and must not resurrect a stale controller.
  int _initGeneration = 0;

  // Only ask once per screen visit — an already-declined-then-retried user
  // gets straight to the OS prompt, not the rationale again.
  bool _rationaleShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final generation = ++_initGeneration;
    setState(() => _status = _Status.initializing);
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      final description = cameras.firstWhere(
        (c) => c.lensDirection == widget.lensDirection,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      if (!_rationaleShown) {
        _rationaleShown = true;
        // Nothing to explain if the OS won't actually prompt — skip
        // straight to initialize() when the permission's already granted.
        final granted = (await Permission.camera.status).isGranted;
        if (!mounted || generation != _initGeneration) return;
        if (!granted) {
          final proceed = await showPermissionRationale(
            context: context,
            icon: Icons.camera_alt_outlined,
            explanation: t.permissionRationale.cameraExplanation,
          );
          if (!mounted || generation != _initGeneration) return;
          if (!proceed) {
            final permanentlyDenied =
                (await Permission.camera.status).isPermanentlyDenied;
            if (!mounted || generation != _initGeneration) return;
            setState(() {
              _status = _Status.permissionDenied;
              _permanentlyDenied = permanentlyDenied;
            });
            return;
          }
        }
      }
      await controller.initialize().timeout(_initTimeout);
      if (!mounted || generation != _initGeneration) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _status = _Status.ready;
      });
    } on CameraException catch (e) {
      if (!mounted || generation != _initGeneration) return;
      setState(() {
        _status =
            e.code == 'CameraAccessDenied' ||
                e.code == 'CameraAccessDeniedWithoutPrompt'
            ? _Status.permissionDenied
            : _Status.error;
        // CameraAccessDeniedWithoutPrompt is the platform's own "don't ask
        // again" signal — only Settings can recover from it.
        _permanentlyDenied = e.code == 'CameraAccessDeniedWithoutPrompt';
      });
    } on TimeoutException {
      // Don't await: a controller stuck mid-initialize can hang dispose()
      // too, and the user needs the retry button back either way.
      unawaited(controller?.dispose());
      if (!mounted || generation != _initGeneration) return;
      setState(() => _status = _Status.error);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _initGeneration++;
      final controller = _controller;
      _controller = null;
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _status != _Status.initializing) {
      _initialize();
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final file = await controller.takePicture();
    if (!mounted) return;
    final Uint8List bytes = await file.readAsBytes();
    if (!mounted) return;
    Navigator.of(context).pop(bytes);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: switch (_status) {
        _Status.initializing => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        _Status.permissionDenied =>
          _permanentlyDenied
              ? _RetryMessage(
                  message: t.camera.permissionBlockedBody,
                  onRetry: openAppSettings,
                  retryLabel: t.permissionGate.openSettings,
                )
              : _RetryMessage(
                  message: t.camera.permissionDeniedBody,
                  onRetry: _initialize,
                ),
        _Status.error => _RetryMessage(
          message: t.camera.errorGeneric,
          onRetry: _initialize,
        ),
        _Status.ready => Stack(
          fit: StackFit.expand,
          children: [
            // CameraController.value.aspectRatio is width/height in the
            // sensor's native (landscape) orientation — invert it for a
            // portrait viewfinder, otherwise StackFit.expand stretches it.
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _capture,
                  child: const FramedIcons(FramedIcon.frame),
                ),
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({
    required this.message,
    required this.onRetry,
    this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel ?? t.camera.retry),
            ),
          ],
        ),
      ),
    );
  }
}
