import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fermah_quiz_hub/confetti.dart';
import 'package:fermah_quiz_hub/main.dart';
import 'package:fermah_quiz_hub/quiz_page.dart';

void main() {
  testWidgets('Fermah Says pads fit on a 390px phone with no overflow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);

    // The four game cards each have a Play button, in order: Proof Pairs,
    // Proof Rush, ZK Scramble, Fermah Says.
    await tester.ensureVisible(find.text('Fermah Says'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play').last);
    await tester.pumpAndSettle();
    expect(find.text('Status: Press Start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'playing the Fermafia Community quiz to the end shows confetti',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The community quiz is the last card, so its Start button is last.
    await tester.ensureVisible(find.text('Fermafia Community'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start quiz').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('What greeting do Fermah'), findsOneWidget);

    // Every correct answer in this quiz is option A. The taps are
    // scoped to the quiz player because 'gFermah' also appears in the
    // hero and the share card.
    const List<String> answers = <String>[
      'gFermah',
      'Pioneer',
      'Fermafia',
      'CoffeeLounge',
      'OG',
      'A team member',
    ];
    for (int i = 0; i < answers.length; i++) {
      await tester.tap(find.descendant(
        of: find.byType(QuizPlayer),
        matching: find.text(answers[i]),
      ));
      await tester.pumpAndSettle();
      if (i < answers.length - 1) {
        await tester.tap(find.text('Next question'));
        await tester.pumpAndSettle();
      }
    }
    await tester.tap(find.text('See my results'));
    await tester.pumpAndSettle();
    expect(find.textContaining('complete'), findsOneWidget);
    // A positive score earns the one celebration in the app.
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
