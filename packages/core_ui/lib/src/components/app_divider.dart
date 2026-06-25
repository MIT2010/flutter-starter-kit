import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Divider dengan style yang konsisten.
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.height,
    this.indent,
    this.endIndent,
  });

  final double? height;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: height ?? AppSpacing.lg,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }
}
