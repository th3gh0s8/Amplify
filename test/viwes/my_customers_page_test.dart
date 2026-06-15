import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpower_partners/views/my_customers_page.dart';

void main() {
  testWidgets('MyCustomersPage displays appbar title and filter chips', (
    WidgetTester tester,
  ) async {
    // Render widget inside test environment:
    await tester.pumpWidget(
      const MaterialApp(home: MyCustomersPage(phoneNumber: '0771234567')),
    );

    // Find elements on screen:
    expect(find.text('MY CUSTOMERS'), findsOneWidget);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);

    // Simulate tap action:
    await tester.tap(find.text('APPROVED'));
    await tester.pump(); // trigger frame redraw
  });
}
