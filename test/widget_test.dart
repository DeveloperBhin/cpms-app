/// CPMS Widget Tests
///
/// Basic widget tests for the CPMS app.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/main.dart';
import '../lib/providers/app_provider.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/language_provider.dart';

void main() {
  testWidgets('CPMS app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Wait for any animations to complete
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the application root is present.
    expect(find.byType(CpmsApp), findsOneWidget);
  });
}
