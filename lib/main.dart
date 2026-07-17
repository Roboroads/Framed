import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injector.dart';
import 'core/push/push_background_handler.dart';
import 'core/push/push_service.dart';
import 'core/session/game_session.dart';
import 'features/game/domain/game_repository.dart';
import 'i18n/strings.g.dart';
import 'core/theme/spacing.dart';

// A real server outage or a bad connection shouldn't leave the user staring
// at the native splash screen forever with no feedback — bound every step
// so a failure always reaches the retry screen below instead of hanging.
const _bootstrapTimeout = Duration(seconds: 15);

// bootstrapFlutter() is mcp_toolkit's own entrypoint — unlike calling
// initialize() directly, its debug-only gate is a real kReleaseMode check,
// not just an assert() that happens to get stripped in release. It also
// covers WidgetsFlutterBinding.ensureInitialized() and the zone-guarded
// error forwarding this file used to set up by hand.
void main() => MCPToolkitBinding.instance.bootstrapFlutter(runApp: _bootstrap);

Future<void> _bootstrap() async {
  // Locale files ship with #64's key parity, but slang starts at the base
  // locale (en) until something explicitly asks for the device's — this
  // is that ask, before the first t.* read below so even the bootstrap
  // error screen renders in the right language.
  await LocaleSettings.useDeviceLocale();
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    ).timeout(_bootstrapTimeout);
    // Every RPC identifies the caller by auth.uid(); sign in once,
    // persisted across restarts by supabase_flutter (see
    // backend/README.md).
    if (Supabase.instance.client.auth.currentSession == null) {
      await Supabase.instance.client.auth.signInAnonymously().timeout(
        _bootstrapTimeout,
      );
    }
    configureDependencies();

    // Push (#28): registered before runApp, and the handler stays a
    // top-level function (FirebaseMessaging reflects on it — see its own
    // doc comment). No project is configured yet (#28's decision), so
    // this — like every push call — degrades to "no push" rather than
    // blocking startup.
    try {
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
    } catch (_) {}
    // Foreground push messages are deliberately left unhandled: realtime
    // already delivers the same event to whatever screen is open, so a
    // system notification on top would just duplicate it (#28's
    // acceptance criteria).
    final pushService = getIt<PushService>();
    pushService.listenForRefresh((token) {
      final session = getIt<GameSession>();
      if (session.isActive) {
        unawaited(
          getIt<GameRepository>().updatePushToken(
            gameId: session.gameId,
            token: token,
          ),
        );
      }
    });

    runApp(TranslationProvider(child: const FramedApp()));
  } catch (_) {
    runApp(TranslationProvider(child: _BootstrapErrorApp(onRetry: _bootstrap)));
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                Gap.lg,
                Text(t.bootstrap.errorGeneric, textAlign: TextAlign.center),
                Gap.lg,
                FilledButton(
                  onPressed: onRetry,
                  child: Text(t.bootstrap.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
