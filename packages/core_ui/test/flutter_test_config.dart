import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// google_fonts coba fetch font dari jaringan kalau tidak ketemu di asset
/// bundle lokal — bikin test lambat/flaky (bahkan gagal total tanpa akses
/// jaringan). Matikan runtime fetching supaya AppTheme.light/dark fallback
/// ke font sistem saat testing, diverifikasi langsung: tanpa ini
/// AppTheme.dark/light melempar "Failed to load font ... Inter-SemiBold".
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
