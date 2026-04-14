// This is a basic Flutter widget test for the RSS Reader app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rss_reader_app/main.dart';

void main() {
  testWidgets('RSS Reader App renders Home Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RssReaderApp());

    // Verify that the app title 'RSS阅读器' is present
    expect(find.text('RSS阅读器'), findsOneWidget);

    // Verify that the main bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that the initial screen contains the IndexedStack
    expect(find.byType(IndexedStack), findsOneWidget);
  });
}
