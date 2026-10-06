import 'package:flutter_test/flutter_test.dart';

import 'package:homeguard_app/main.dart';

void main() {
  testWidgets('HomeGuardApp splash smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeGuardApp());

    // Verify HGA text is present on splash screen
    expect(find.text('HGA'), findsOneWidget);
    expect(find.text('home security at a go'), findsOneWidget);
  });
}
