// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_hub/main.dart';

void main() {
  testWidgets('Movie Hub app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MovieHubApp());

    // Verify that the Movie Hub title appears
    expect(find.text('Movie Hub'), findsOneWidget);
    
    // Verify that we can find the search field
    expect(find.byType(TextField), findsOneWidget);
  });
}
