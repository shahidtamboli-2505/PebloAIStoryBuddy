import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peblo_ai_story_buddy/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const PebloApp());

    // Verify the app title is rendered.
    expect(find.text('✨ Peblo AI ✨'), findsOneWidget);
    expect(find.text('Story Buddy & Quiz'), findsOneWidget);
  });

  testWidgets('Read Me a Story button is present', (WidgetTester tester) async {
    await tester.pumpWidget(const PebloApp());

    // The idle-state button label
    expect(find.text('Read Me a Story! 📖'), findsOneWidget);
  });
}
