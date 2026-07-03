import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets (bukan test polos) sengaja dipakai di sini — AppTheme
  // membangun TextTheme lewat GoogleFonts, yang men-trigger Future
  // asinkron di belakang layar (fetch/load font). Dengan test() polos,
  // Future itu baru reject SETELAH body sinkron selesai, muncul sebagai
  // "test failed after it had already completed" dan salah dilaporkan
  // ke test lain. testWidgets + pump mengalirkan microtask yang pending
  // itu ke test yang sama sebelum dianggap selesai.
  testWidgets('AppTheme.light pakai Material3 dan brightness light', (
    tester,
  ) async {
    final theme = AppTheme.light;
    await tester.pump();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  testWidgets('AppTheme.dark pakai Material3 dan brightness dark', (
    tester,
  ) async {
    final theme = AppTheme.dark;
    await tester.pump();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppColors.primaryLight);
  });
}
