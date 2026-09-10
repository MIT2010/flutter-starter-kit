import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/app/widgets/confirm_dialog.dart';

void main() {
  /// Pumps a screen with one button that opens the dialog and stores its
  /// result, taps the button, then runs [dismiss] to close the dialog.
  Future<bool?> run(
    WidgetTester tester,
    Future<void> Function(WidgetTester) dismiss,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => result = await confirmDialog(
                context,
                title: 'Delete?',
                message: 'This cannot be undone.',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await dismiss(tester);
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('returns true only when Confirm is tapped', (tester) async {
    final result = await run(
      tester,
      (t) => t.tap(find.widgetWithText(TextButton, 'Confirm')),
    );
    expect(result, isTrue);
  });

  testWidgets('returns false when Cancel is tapped', (tester) async {
    final result = await run(
      tester,
      (t) => t.tap(find.widgetWithText(TextButton, 'Cancel')),
    );
    expect(result, isFalse);
  });

  testWidgets('returns false when dismissed by tapping the barrier', (
    tester,
  ) async {
    final result = await run(tester, (t) => t.tapAt(const Offset(10, 10)));
    expect(result, isFalse);
  });
}
