import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fermah_quiz_hub/main.dart';

void main() {
  testWidgets('tapping Start quiz opens the first question',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await tester.ensureVisible(find.text('Fermah Basics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start quiz').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('What is Fermah, in one line?'),
        findsOneWidget);
    // Answer option A, which is correct.
    await tester.tap(find.text('The universal proof generation layer'));
    await tester.pumpAndSettle();
    // The score chip must show points above zero now.
    expect(find.text('0 pts Seeker'), findsNothing);
    // The chip shows "<total> pts <rank>"; the total depends on how much
    // of the 20 second timer was left when the answer was tapped.
    expect(find.textContaining(RegExp(r'^[1-9][0-9]* pts')), findsWidgets);
  });
}
