import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan child', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppCard(child: Text('Isi card'))),
    );
    expect(find.text('Isi card'), findsOneWidget);
  });

  testWidgets('tanpa onTap tidak bisa di-tap (bukan GestureDetector)', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithApp(const AppCard(child: Text('Statis'))));
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('dengan onTap memanggil callback saat di-tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWithApp(
        AppCard(onTap: () => tapped = true, child: const Text('Bisa di-tap')),
      ),
    );

    await tester.tap(find.text('Bisa di-tap'));
    expect(tapped, isTrue);
  });
}
