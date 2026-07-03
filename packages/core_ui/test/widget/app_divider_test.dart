import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('height default AppSpacing.lg', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppDivider()));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.height, AppSpacing.lg);
  });

  testWidgets('height custom dipakai kalau di-set', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppDivider(height: 40)));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.height, 40);
  });
}
