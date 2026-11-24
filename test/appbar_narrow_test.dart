import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fermah_quiz_hub/main.dart';

void main() {
  testWidgets('AppBar title is fully readable at 390px, chip moves to hero',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // No layout exceptions (no RenderFlex overflow anywhere).
    expect(tester.takeException(), isNull);

    // The short app name is present in the AppBar and not truncated.
    final Finder titleFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Fermah'),
    );
    expect(titleFinder, findsOneWidget);
    final RenderParagraph titleParagraph =
        tester.renderObject<RenderParagraph>(titleFinder);
    expect(titleParagraph.didExceedMaxLines, isFalse);

    // The full name and subtitle stay on wide screens only.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Fermah Quiz Hub'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Quizzes and games for the Fermafia'),
      ),
      findsNothing,
    );

    // The score chip must not crowd the AppBar on a narrow screen.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('0 pts'),
      ),
      findsNothing,
    );
    // ...but it is still on the page, in the hero below the AppBar.
    expect(find.text('0 pts'), findsOneWidget);
  });

  testWidgets('AppBar keeps the score chip on a wide screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FermahQuizHubApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(tester.takeException(), isNull);
    expect(find.text('Fermah Quiz Hub'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('0 pts'),
      ),
      findsOneWidget,
    );
  });
}
