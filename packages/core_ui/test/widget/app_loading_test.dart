import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('menampilkan spinner tanpa message', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AppLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('menampilkan message kalau diisi', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(const AppLoading(message: 'Memuat data...')),
    );
    expect(find.text('Memuat data...'), findsOneWidget);
  });

  testWidgets('AppLoading.fullScreen tetap menampilkan spinner', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithApp(const AppLoading.fullScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
