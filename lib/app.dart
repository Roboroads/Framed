import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';
import 'i18n/strings.g.dart';

class FramedApp extends StatelessWidget {
  const FramedApp({this.navigatorKey, super.key});

  /// Lets a deep link (DeepLinkService) push a route without a
  /// [BuildContext] of its own. Null outside the real entrypoint (e.g. the
  /// debug driver) — those don't need to handle incoming links.
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: t.app.title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomePage(),
    );
  }
}
