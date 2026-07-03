import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Badge/chip untuk menampilkan status atau label kecil.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  const AppBadge.success({super.key, required this.label})
    : color = AppColors.success,
      backgroundColor = AppColors.successLight;

  const AppBadge.warning({super.key, required this.label})
    : color = AppColors.warning,
      backgroundColor = AppColors.warningLight;

  const AppBadge.error({super.key, required this.label})
    : color = AppColors.error,
      backgroundColor = AppColors.errorLight;

  const AppBadge.info({super.key, required this.label})
    : color = AppColors.info,
      backgroundColor = AppColors.infoLight;

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}
