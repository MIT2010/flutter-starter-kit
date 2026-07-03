import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Theme utama aplikasi berbasis Material 3.
abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.neutral50,
    appBarTheme: _appBarTheme(isDark: false),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(isDark: false),
    cardTheme: _cardTheme(isDark: false),
    dividerTheme: _dividerTheme(isDark: false),
    bottomNavigationBarTheme: _bottomNavTheme(isDark: false),
    chipTheme: _chipTheme(isDark: false),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.neutral900,
    appBarTheme: _appBarTheme(isDark: true),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(isDark: true),
    cardTheme: _cardTheme(isDark: true),
    dividerTheme: _dividerTheme(isDark: true),
    bottomNavigationBarTheme: _bottomNavTheme(isDark: true),
    chipTheme: _chipTheme(isDark: true),
  );

  // ── Color Schemes ─────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.neutral900,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.neutral900,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
  );

  // ── Component Themes ──────────────────────────────────────

  static AppBarTheme _appBarTheme({required bool isDark}) => AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
    foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    titleTextStyle: AppTypography.headingSm.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSpacing.radiusMd),
            ),
          ),
          textStyle: AppTypography.buttonMd,
          elevation: 0,
        ),
      );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSpacing.radiusMd),
            ),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTypography.buttonMd,
        ),
      );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTypography.buttonMd,
    ),
  );

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.neutral800 : AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMd.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        labelStyle: AppTypography.labelMd.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      );

  static CardThemeData _cardTheme({required bool isDark}) => CardThemeData(
    elevation: 0,
    color: isDark ? AppColors.neutral800 : AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
    ),
    margin: EdgeInsets.zero,
  );

  static DividerThemeData _dividerTheme({required bool isDark}) =>
      DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.border,
        thickness: 1,
        space: 0,
      );

  static BottomNavigationBarThemeData _bottomNavTheme({required bool isDark}) =>
      BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      );

  static ChipThemeData _chipTheme({required bool isDark}) => ChipThemeData(
    backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral100,
    labelStyle: AppTypography.labelSm.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    ),
    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    ),
  );
}
