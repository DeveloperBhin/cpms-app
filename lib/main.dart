/// Cashew Production Management System
///
/// Main entry point of the application.
///
/// The application:
/// - Uses Provider for state management
/// - Uses Material 3
/// - Always uses the application's light theme
/// - Does NOT follow the device dark/light mode
/// - Starts with SplashPage

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash_page.dart';
import 'providers/app_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),
      ],

      child: MaterialApp(
        title: 'Cashew Production Management System',

        debugShowCheckedModeBanner: false,

        // =========================================================
        // ALWAYS USE LIGHT THEME
        // =========================================================
        themeMode: ThemeMode.light,

        // =========================================================
        // APPLICATION THEME
        // =========================================================
        theme: ThemeData(
          useMaterial3: true,

          brightness: Brightness.light,

          scaffoldBackgroundColor: Colors.white,

          colorScheme: const ColorScheme.light(
            primary: Color(0xFF11732E),
            onPrimary: Colors.white,

            secondary: Color(0xFF11732E),
            onSecondary: Colors.white,

            surface: Colors.white,
            onSurface: Color(0xFF1A1A1A),

            error: Colors.red,
            onError: Colors.white,
          ),

          // =======================================================
          // APP BAR
          // =======================================================
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1A1A),
            elevation: 0,
            centerTitle: false,
          ),

          // =======================================================
          // CARD
          // =======================================================
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // =======================================================
          // ELEVATED BUTTON
          // =======================================================
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11732E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // =======================================================
          // FLOATING ACTION BUTTON
          // =======================================================
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF11732E),
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          // =======================================================
          // TEXT BUTTON
          // =======================================================
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF11732E),
            ),
          ),

          // =======================================================
          // INPUT FIELDS
          // =======================================================
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF11732E),
                width: 2,
              ),
            ),
          ),

          // =======================================================
          // BOTTOM NAVIGATION
          // =======================================================
          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF11732E),
            unselectedItemColor: Colors.grey,
          ),

          // =======================================================
          // DIVIDER
          // =======================================================
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE5E5E5),
            thickness: 1,
          ),
        ),

        // =========================================================
        // NO DARK THEME
        // =========================================================
        //
        // We intentionally do not define darkTheme.
        //
        // themeMode: ThemeMode.light guarantees that the application
        // remains in light mode even if the device is in dark mode.
        //
        // =========================================================

        home: const SplashPage(),
      ),
    );
  }
}