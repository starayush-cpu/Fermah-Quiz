import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fermah_quiz_hub/share_card.dart';
import 'package:fermah_quiz_hub/theme.dart';

void main() {
  testWidgets('Copy caption shows feedback', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ShareCardSection(totalScore: 200),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Copy caption'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final bool copied =
        find.text('Caption copied.').evaluate().isNotEmpty;
    final bool fallback = find
        .text(
          'Copy did not work automatically, select the caption and copy it yourself.',
        )
        .evaluate()
        .isNotEmpty;
    expect(copied || fallback, isTrue,
        reason: 'tapping Copy caption must show some feedback');
  });

  testWidgets('Download card PNG shows feedback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ShareCardSection(totalScore: 200),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Download card PNG'));
    await tester.pump();
    await tester.tap(find.text('Download card PNG'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 5)),
    );
    await tester.pump();
    final bool done =
        find.text('Card downloaded. Post it on X or Discord with the caption.')
            .evaluate()
            .isNotEmpty;
    final bool failed = find
        .text('Download did not work here. Try again in a moment.')
        .evaluate()
        .isNotEmpty;
    expect(done || failed, isTrue,
        reason: 'tapping Download card PNG must show some feedback');
  });
}
