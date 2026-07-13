import 'package:flutter/material.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injector.dart';
import 'i18n/strings.g.dart';

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
