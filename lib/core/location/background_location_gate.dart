import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../i18n/strings.g.dart';

enum _GateStatus { explaining, requesting, blocked }

/// Shown once, at the lobby-to-ingame transition: background location is
/// mandatory to meaningfully play (IDEA.md "Known risks") — a player who
/// can't grant it can't be found by their target's compass or enforced by
/// the geofence. Explains why before either platform's OS dialog appears,
/// requests "while in use" then escalates toward background, and falls
/// back to a blocked-state screen with a Settings deep link when denied.
class BackgroundLocationGate extends StatefulWidget {
  const BackgroundLocationGate({required this.initialEndsAt, super.key});

  /// Passed straight through to IngamePage once permission is granted.
  final DateTime initialEndsAt;

  @override
  State<BackgroundLocationGate> createState() => _BackgroundLocationGateState();
}

class _BackgroundLocationGateState extends State<BackgroundLocationGate>
    with WidgetsBindingObserver {
  _GateStatus _status = _GateStatus.explaining;

  // The OS permission dialog itself cycles inactive->resumed, same as
  // actually backgrounding the app — the only way to tell "came back from
  // Settings" from "the in-app permission dialog just closed" is that the
  // former passes through `paused` first (the app is truly backgrounded)
  // and the latter never does (the dialog overlays this same foreground
  // task). Without this, resumed-after-in-app-dialog re-triggers the
  // request immediately, showing a second dialog right after the first
  // (see PermissionGate, #52, where this was caught live on device).
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _status = _GateStatus.requesting);

    // Best-effort: the foreground-service notification needs this on
    // Android 13+, but a denial doesn't block tracking or the geofence, so
    // it never gates entry into the game.
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _status = _GateStatus.blocked);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // Android 10+ only offers "while in use" from the in-app dialog past a
    // point; a second request call is how the plugin surfaces the
    // background escalation where the platform still allows asking in-app.
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) return;
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      context.go('/ingame', extra: widget.initialEndsAt);
      return;
    }
    setState(() => _status = _GateStatus.blocked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: switch (_status) {
              _GateStatus.explaining => _Explainer(
                onContinue: _requestPermission,
              ),
              _GateStatus.requesting => const CircularProgressIndicator(),
              _GateStatus.blocked => _Blocked(
                onOpenSettings: Geolocator.openAppSettings,
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
        const Icon(Icons.location_on_outlined, size: 48),
        const SizedBox(height: 16),
        Text(
          t.locationGate.explainerTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(t.locationGate.explainerBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onContinue,
          child: Text(t.locationGate.continueButton),
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
        const Icon(Icons.location_off_outlined, size: 48),
        const SizedBox(height: 16),
        Text(
          t.locationGate.blockedTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(t.locationGate.blockedBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onOpenSettings,
          child: Text(t.locationGate.openSettings),
        ),
      ],
    );
  }
}
