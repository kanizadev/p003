// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:p003/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Verify that our weather app displays correctly.
    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('New York'), findsOneWidget);
    expect(find.text('22°'), findsOneWidget);
    expect(find.text('Sunny'), findsOneWidget);
  });
}
