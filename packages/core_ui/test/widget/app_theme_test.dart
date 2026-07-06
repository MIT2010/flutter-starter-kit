import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sebelumnya file ini WAJIB pakai testWidgets+pump() karena AppTheme
  // membangun TextTheme lewat GoogleFonts, yang men-trigger Future asinkron
  // di belakang layar (fetch/load font) — dengan test() polos, Future itu
  // baru reject SETELAH body sinkron selesai dan salah dilaporkan ke test
  // lain. Sejak AppTypography pindah ke font Inter yang di-bundle sebagai
  // asset lokal (lihat lib/src/tokens/app_typography.dart), semuanya
  // sinkron lagi — test() polos sudah cukup, tidak perlu widget pump.
  test('AppTheme.light pakai Material3 dan brightness light', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  test('AppTheme.dark pakai Material3 dan brightness dark', () {
    final theme = AppTheme.dark;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppColors.primaryLight);
  });
}
