// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_connect/main.dart';

void main() {
  testWidgets('Course Connect App Navigation Test', (WidgetTester tester) async {
    await tester.pumpWidget(CourseConnectApp());

    // Test initial home screen
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);

    // Test navigation to Wishlist
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.text('Wishlist'), findsOneWidget);

    // Test navigation to Dashboard
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
