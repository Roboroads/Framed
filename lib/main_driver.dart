// Debug-only entrypoint that enables the Flutter Driver extension so an
// agent (or `flutter drive`) can screenshot/tap the running app. Never
// shipped — not referenced by android/ios build configs, only launched
// explicitly via `flutter run -t lib/main_driver.dart`.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injector.dart';
import 'i18n/strings.g.dart';

void main() {
  enableFlutterDriverExtension();
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      MCPToolkitBinding.instance
        ..initialize()
        ..initializeFlutterToolkit();
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
      if (Supabase.instance.client.auth.currentSession == null) {
        await Supabase.instance.client.auth.signInAnonymously();
      }
      configureDependencies();
      runApp(TranslationProvider(child: const FramedApp()));
    },
    (error, stack) => MCPToolkitBinding.instance.handleZoneError(error, stack),
  );
}
