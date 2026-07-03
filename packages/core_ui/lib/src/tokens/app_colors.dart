import 'package:flutter/material.dart';

/// Design tokens untuk warna.
/// Semua warna di seluruh aplikasi harus merujuk ke sini.
/// Jangan gunakan Color(0xFF...) langsung di widget.
abstract class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  // Warna utama aplikasi — ganti di sini untuk rebranding
  static const Color primary = Color(0xFF2563EB); // Biru utama
  static const Color primaryLight = Color(0xFF60A5FA); // Biru muda
  static const Color primaryDark = Color(0xFF1D4ED8); // Biru tua
  static const Color onPrimary = Color(0xFFFFFFFF); // Teks di atas primary

  static const Color secondary = Color(0xFF7C3AED); // Ungu
  static const Color secondaryLight = Color(0xFFA78BFA); // Ungu muda
  static const Color secondaryDark = Color(0xFF5B21B6); // Ungu tua
  static const Color onSecondary = Color(0xFFFFFFFF); // Teks di atas secondary

  // ── Semantic ─────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A); // Hijau
  static const Color successLight = Color(0xFFBBF7D0); // Hijau muda
  static const Color warning = Color(0xFFD97706); // Kuning
  static const Color warningLight = Color(0xFFFDE68A); // Kuning muda
  static const Color error = Color(0xFFDC2626); // Merah
  static const Color errorLight = Color(0xFFFECACA); // Merah muda
  static const Color info = Color(0xFF0284C7); // Biru info
  static const Color infoLight = Color(0xFFBAE6FD); // Biru info muda

  // ── Neutral (Light Mode) ─────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ── Surface ──────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF0F172A);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ── Border ───────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // ── Assessment (warna khusus untuk fitur tes) ─────────────
  static const Color assessmentCorrect = Color(0xFF16A34A);
  static const Color assessmentIncorrect = Color(0xFFDC2626);
  static const Color assessmentNeutral = Color(0xFF64748B);
  static const Color assessmentTimer = Color(0xFFD97706);
  static const Color assessmentTimerCritical = Color(0xFFDC2626);
}
