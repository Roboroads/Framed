import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/di/injector.dart';
import 'features/lobby/presentation/join/join_page.dart';
import 'i18n/strings.g.dart';

// A real server outage or a bad connection shouldn't leave the user staring
// at the native splash screen forever with no feedback — bound every step
// so a failure always reaches the retry screen below instead of hanging.
const _bootstrapTimeout = Duration(seconds: 15);

void main() => runWithMcpToolkit(_bootstrap);

/// Runs [body] inside a zone guarded by MCPToolkitBinding — the bindings
/// this file and the debug-only lib/main_driver.dart both need before
/// their own entrypoint logic.
void runWithMcpToolkit(FutureOr<void> Function() body) {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      MCPToolkitBinding.instance
        ..initialize()
        ..initializeFlutterToolkit();
      await body();
    },
    (error, stack) => MCPToolkitBinding.instance.handleZoneError(error, stack),
  );
}

Future<void> _bootstrap() async {
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
    final navigatorKey = GlobalKey<NavigatorState>();
    unawaited(
      DeepLinkService((payload) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => JoinPage(
              joinToken: payload.joinToken,
              gameKeyBytes: payload.keyBytes,
            ),
          ),
        );
      }).start(),
    );
    runApp(TranslationProvider(child: FramedApp(navigatorKey: navigatorKey)));
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(t.bootstrap.errorGeneric, textAlign: TextAlign.center),
                const SizedBox(height: 16),
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
