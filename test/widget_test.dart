import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodify/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodifyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
