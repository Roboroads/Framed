import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../i18n/strings.g.dart';
import '../theme/spacing.dart';

enum _GateStatus { explaining, requesting, blocked }

/// Shown before the host/join flow (#52): camera, foreground+background
/// location, and (best-effort) notifications are all requested here, up
/// front, instead of scattered across pre-join/lobby/ingame — so a denial
/// is caught before the player invests time in name entry and a selfie.
/// Denying camera or location blocks entry, reusing the same
/// explain-then-block pattern as [BackgroundLocationGate]; notifications
/// stay best-effort and never block, matching that gate too. A returning
/// player who already granted everything never sees the explainer —
/// it's rationale for a dialog, and there's nothing left to ask.
class PermissionGate extends StatefulWidget {
  const PermissionGate({required this.nextRoute, super.key});

  /// Route this gate replaces itself with once every required permission is
  /// granted (`/host-setup` or `/scan`).
  final String nextRoute;

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate>
    with WidgetsBindingObserver {
  // Spinner while the silent pre-check below runs — the explainer is
  // rationale for a dialog we're about to show, so it has no reason to
  // appear if everything's already granted (e.g. a returning player).
  _GateStatus _status = _GateStatus.requesting;

  // The OS permission dialog itself cycles inactive->resumed, same as
  // actually backgrounding the app — the only way to tell "came back from
  // Settings" from "the in-app permission dialog just closed" is that the
  // former passes through `paused` first (the app is truly backgrounded)
  // and the latter never does (the dialog overlays this same foreground
  // task). Without this, resumed-after-in-app-dialog re-triggers the
  // request immediately, showing a second dialog right after the first.
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkThenProceed());
  }

  /// Non-prompting check: if camera and location are already granted, skip
  /// straight through instead of showing rationale for a dialog nobody's
  /// about to see.
  Future<void> _checkThenProceed() async {
    final camera = await Permission.camera.status;
    final location = await Geolocator.checkPermission();
    final locationGranted =
        location == LocationPermission.always ||
        location == LocationPermission.whileInUse;
    if (!mounted) return;
    if (camera.isGranted && locationGranted) {
      await _requestPermissions();
    } else {
      setState(() => _status = _GateStatus.explaining);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      return;
    }
    // Recheck on return from the Settings app — no app restart needed.
    if (state == AppLifecycleState.resumed &&
        _status == _GateStatus.blocked &&
        _wasPaused) {
      _wasPaused = false;
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _status = _GateStatus.requesting);

    final camera = await Permission.camera.request();
    if (!mounted) return;
    if (!camera.isGranted) {
      setState(() => _status = _GateStatus.blocked);
      return;
    }

    // Best-effort, same as BackgroundLocationGate: a denial doesn't block
    // entry, it just means no foreground-service notification later.
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _status = _GateStatus.blocked);
      return;
    }
    var location = await Geolocator.checkPermission();
    if (location == LocationPermission.denied) {
      location = await Geolocator.requestPermission();
    }
    // Android 10+ only offers "while in use" from the in-app dialog past a
    // point; a second request call is how the plugin surfaces the
    // background escalation where the platform still allows asking in-app.
    if (location == LocationPermission.whileInUse) {
      location = await Geolocator.requestPermission();
    }

    if (!mounted) return;
    if (location == LocationPermission.always ||
        location == LocationPermission.whileInUse) {
      context.pushReplacement(widget.nextRoute);
      return;
    }
    setState(() => _status = _GateStatus.blocked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Center(
            child: switch (_status) {
              _GateStatus.explaining => _Explainer(
                onContinue: _requestPermissions,
              ),
              _GateStatus.requesting => const CircularProgressIndicator(),
              _GateStatus.blocked => const _Blocked(
                onOpenSettings: openAppSettings,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Explainer extends StatelessWidget {
  const _Explainer({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shield_outlined, size: 48),
        Gap.lg,
        Text(
          t.permissionGate.explainerTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Gap.sm,
        Text(t.permissionGate.explainerBody, textAlign: TextAlign.center),
        Gap.xl,
        FilledButton(
          onPressed: onContinue,
          child: Text(t.permissionGate.continueButton),
        ),
      ],
    );
  }
}

class _Blocked extends StatelessWidget {
  const _Blocked({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.block, size: 48),
        Gap.lg,
        Text(
          t.permissionGate.blockedTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Gap.sm,
        Text(t.permissionGate.blockedBody, textAlign: TextAlign.center),
        Gap.xl,
        FilledButton(
          onPressed: onOpenSettings,
          child: Text(t.permissionGate.openSettings),
        ),
      ],
    );
  }
}
