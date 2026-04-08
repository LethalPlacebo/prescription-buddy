import 'package:flutter_test/flutter_test.dart';

import 'package:prescription_buddy_flutter/app.dart';

void main() {
  testWidgets('renders authentication entry screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrescriptionBuddyApp());

    expect(find.textContaining('Prescription Buddy account'), findsWidgets);
    expect(find.text('Log in'), findsOneWidget);
  });
}
