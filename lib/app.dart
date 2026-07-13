import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'i18n/strings.g.dart';

class FramedApp extends StatelessWidget {
  const FramedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: t.app.title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
  }
}
