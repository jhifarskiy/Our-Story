import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/main.dart';

void main() {
  testWidgets('App should start without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OurStoryApp());

    // Verify that app starts with splash screen or home screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
