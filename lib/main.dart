import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

import 'pages/splash_page.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'services/local_data_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(
    LocalDataService.instance.startConnectivityListener(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const CpmsApp(),
    ),
  );
}

class CpmsApp extends StatelessWidget {
  const CpmsApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Cashew Production Management System',

      // =========================================================
      // LOCALIZATION
      // =========================================================

      locale: languageProvider.locale,

      localizationsDelegates:
          AppLocalizations.localizationsDelegates,

      supportedLocales:
          AppLocalizations.supportedLocales,

      // =========================================================
      // THEME
      // =========================================================

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF11732E),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(
          color: Color(0xFF11732E),
        ),
      ),

      // =========================================================
      // START PAGE
      // =========================================================

      home: const SplashPage(),
    );
  }
}