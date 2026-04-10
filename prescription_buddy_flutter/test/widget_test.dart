import 'package:flutter_test/flutter_test.dart';

import 'package:prescription_buddy_flutter/app.dart';

void main() {
  testWidgets('shows splash then renders authentication entry screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrescriptionBuddyApp());

    expect(find.text('Prescription Buddy'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));

    expect(find.textContaining('Prescription Buddy account'), findsWidgets);
    expect(find.text('Log in'), findsOneWidget);
  });
}
