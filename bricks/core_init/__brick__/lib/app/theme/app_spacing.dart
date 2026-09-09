import 'package:flutter/material.dart';

/// A fixed spacing scale, exposed as a [ThemeExtension] so widgets read
/// `context.spacing.md` instead of scattering bare `16`s through the tree.
///
/// This is the one piece of "design system" this starter kit ships, and
/// it is deliberately empty of visual opinion: it is a *scale*, not a
/// palette, a font, or a component. The numbers below are an ordinary
/// 4-based step scale — change them, add steps, or delete this file
/// entirely if your design defines spacing differently. Nothing else in
/// the kit depends on these specific values.
///
/// Downstream apps have twice, independently, rebuilt exactly this during
/// a visual redesign (see `docs/MIGRATION-PLAYBOOK.md`). Shipping the
/// mechanism — not any particular look — saves that rework without
/// imposing an identity.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// The default scale. Also the fallback `context.spacing` resolves to
  /// when no [AppSpacing] is registered on the ambient theme — so a bare
  /// `MaterialApp()` / `ThemeData()` in a widget test still works without
  /// every test having to build a full app theme.
  const AppSpacing.standard()
    : xs = 4,
      sm = 8,
      md = 16,
      lg = 24,
      xl = 32,
      xxl = 48;

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      xl: lerpDouble(xl, other.xl, t),
      xxl: lerpDouble(xxl, other.xxl, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// `context.spacing.md` — the intended read path. Falls back to
/// [AppSpacing.standard] when the theme carries no [AppSpacing], so it is
/// always safe to call.
extension AppSpacingContext on BuildContext {
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? const AppSpacing.standard();
}
