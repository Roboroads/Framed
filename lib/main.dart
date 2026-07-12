import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injector.dart';
import 'i18n/strings.g.dart';

void main() {
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
      // Every RPC identifies the caller by auth.uid(); sign in once,
      // persisted across restarts by supabase_flutter (see
      // backend/README.md).
      if (Supabase.instance.client.auth.currentSession == null) {
        await Supabase.instance.client.auth.signInAnonymously();
      }
      configureDependencies();
      runApp(TranslationProvider(child: const FramedApp()));
    },
    (error, stack) => MCPToolkitBinding.instance.handleZoneError(error, stack),
  );
}
