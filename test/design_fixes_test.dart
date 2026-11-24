import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fermah_quiz_hub/confetti.dart';
import 'package:fermah_quiz_hub/data.dart';
import 'package:fermah_quiz_hub/games.dart';
import 'package:fermah_quiz_hub/main.dart';
import 'package:fermah_quiz_hub/quiz_page.dart';
import 'package:fermah_quiz_hub/rolling_number.dart';

void main() {
  testWidgets('best score on the quiz card updates after a finished quiz',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Before playing, every quiz card shows a best of 0.
    expect(find.text('Your best: 0 pts'), findsNWidgets(6));

    // Play the Fermafia Community quiz to the end. Every correct
    // answer in this quiz is option A.
    await tester.ensureVisible(find.text('Fermafia Community'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start quiz').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('What greeting do Fermah'), findsOneWidget);
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

    // The card above the player must now show a real best score, not 0.
    await tester.ensureVisible(find.text('Fermafia Community'));
    await tester.pumpAndSettle();
    expect(find.text('Your best: 0 pts'), findsNWidgets(5));
    expect(find.textContaining(RegExp(r'Your best: [1-9]')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quitting a quiz with points shows confetti',
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

    // Answer the first question correctly, then quit.
    await tester.tap(find.text('The universal proof generation layer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit quiz'));
    await tester.pumpAndSettle();
    expect(find.textContaining('complete'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the quiz timer stops once an answer is locked in',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.ensureVisible(find.text('Fermah Basics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start quiz').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('The universal proof generation layer'));
    await tester.pump();
    final Finder timerFinder =
        find.textContaining(RegExp(r'^\d+s$'), findRichText: false);
    final String before =
        tester.widget<Text>(timerFinder).data ?? '';
    expect(before, isNotEmpty);

    // Five seconds of fake time pass. A running timer would tick down;
    // a stopped one shows the same number.
    await tester.pump(const Duration(seconds: 5));
    final String after =
        tester.widget<Text>(timerFinder).data ?? '';
    expect(after, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RollingNumber counts up visibly and restarts from the shown value',
      (WidgetTester tester) async {
    const TextStyle style = TextStyle(fontSize: 20);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RollingNumber(value: 120, suffix: ' pts', style: style),
        ),
      ),
    );
    await tester.pump();
    // Partway through the 1200ms count the number is between 0 and 120.
    await tester.pump(const Duration(milliseconds: 600));
    final String mid = tester.widget<Text>(find.byType(Text)).data ?? '';
    final int midValue = int.parse(mid.split(' ').first);
    expect(midValue, greaterThan(0));
    expect(midValue, lessThan(120));
    await tester.pumpAndSettle();
    expect(find.text('120 pts'), findsOneWidget);

    // Changing the value counts up from 120, not from 0 and not by
    // jumping straight to the new value.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RollingNumber(value: 200, suffix: ' pts', style: style),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final String mid2 = tester.widget<Text>(find.byType(Text)).data ?? '';
    final int midValue2 = int.parse(mid2.split(' ').first);
    expect(midValue2, greaterThan(120));
    expect(midValue2, lessThan(200));
    await tester.pumpAndSettle();
    expect(find.text('200 pts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'ZK Scramble checks itself as you type and the end screen has Play again',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.ensureVisible(find.text('ZK Scramble'));
    await tester.pumpAndSettle();
    // The game cards are in order: Proof Pairs, Proof Rush, ZK Scramble,
    // Fermah Says. The third Play button opens ZK Scramble.
    await tester.tap(find.text('Play').at(2));
    await tester.pumpAndSettle();
    expect(find.text('Word 1 of ${scrambleWords.length}'), findsOneWidget);

    // Solve every word by typing it. The game must advance on its own
    // as soon as the word is complete, with no Check tap.
    String scrambledWord() {
      final Text textWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (Widget w) => w is Text && w.style?.fontSize == 30,
        ),
      );
      return textWidget.data ?? '';
    }

    String solveWord(String scrambled) {
      final List<String> letters = scrambled.split('')..sort();
      final String key = letters.join();
      for (final ScrambleWord w in scrambleWords) {
        final List<String> wordLetters = w.word.split('')..sort();
        if (wordLetters.join() == key) return w.word;
      }
      fail('no scramble word matches the letters $scrambled');
    }

    for (int i = 0; i < scrambleWords.length; i++) {
      final String answer = solveWord(scrambledWord());
      await tester.enterText(
        find.descendant(
          of: find.byType(ZkScrambleGame),
          matching: find.byType(TextField),
        ),
        answer,
      );
      await tester.pumpAndSettle();
      if (i < scrambleWords.length - 1) {
        expect(find.text('Word ${i + 2} of ${scrambleWords.length}'),
            findsOneWidget);
      }
    }
    expect(find.textContaining('Done! You unscrambled'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(find.text('Word 1 of ${scrambleWords.length}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('footer says scores save to the live leaderboard',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 2000));
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(
      find.textContaining('Leaderboard scores are saved to the live leaderboard'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
