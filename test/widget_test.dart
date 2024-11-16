import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/screens/quiz_screen.dart';

void main() {
  testWidgets('Quiz screen loads with questions', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the QuizScreen is loaded.
    expect(find.byType(QuizScreen), findsOneWidget);

    // Wait for the FutureBuilder to complete fetching questions (if applicable).
    await tester.pumpAndSettle();

    // Verify that at least one question text is displayed.
    expect(find.textContaining('?'), findsWidgets);

    // Verify that options are displayed as ListTiles (assuming options are list items).
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('Timer displays on quiz screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for the FutureBuilder to complete.
    await tester.pumpAndSettle();

    // Verify that the timer is displayed in the format "Time Left: MM:SS".
    expect(find.textContaining('Time Left:'), findsOneWidget);
  });
}
