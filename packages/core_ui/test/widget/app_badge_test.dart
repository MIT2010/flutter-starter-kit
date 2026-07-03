import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan label', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppBadge(label: 'Baru')));
    expect(find.text('Baru'), findsOneWidget);
  });

  testWidgets('AppBadge.success pakai warna success', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppBadge.success(label: 'Aktif')),
    );
    final text = tester.widget<Text>(find.text('Aktif'));
    expect(text.style?.color, AppColors.success);
  });

  testWidgets('AppBadge.error pakai warna error', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppBadge.error(label: 'Gagal')));
    final text = tester.widget<Text>(find.text('Gagal'));
    expect(text.style?.color, AppColors.error);
  });
}
