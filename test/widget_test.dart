// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:projectflow/app.dart';

void main() {
  testWidgets('ProjectFlow AI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ProjectFlowApp()));

    // Wait for the app to fully render
    await tester.pumpAndSettle();

    // Verify that we can find the app title and welcome message
    expect(find.text('ProjectFlow AI'), findsOneWidget);
    expect(find.text('Welcome to ProjectFlow AI'), findsOneWidget);

    // Verify that the create project button is present
    expect(find.text('Create Your First Project'), findsOneWidget);
  });
}