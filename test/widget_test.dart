import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/screens/home_page.dart';

void main() {
  testWidgets('HomePage renders correctly', (WidgetTester tester) async {
    // provide a mock userId for testing
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(userId: 1), // Add the required userId
      ),
    );

    // add your test assertions here
    expect(find.text('Pok-Codex'), findsOneWidget);
  });
}
