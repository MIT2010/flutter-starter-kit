import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

enum AppButtonSize { sm, md, lg }

/// Button component dengan loading state dan berbagai variant.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;

  double get _height => switch (size) {
    AppButtonSize.sm => AppSpacing.buttonHeightSm,
    AppButtonSize.md => AppSpacing.buttonHeightMd,
    AppButtonSize.lg => AppSpacing.buttonHeightLg,
  };

  TextStyle get _textStyle => switch (size) {
    AppButtonSize.sm => AppTypography.buttonMd,
    AppButtonSize.md => AppTypography.buttonMd,
    AppButtonSize.lg => AppTypography.buttonLg,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = !isDisabled && !isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: _height,
      child: switch (variant) {
        AppButtonVariant.primary => _buildElevated(context, isActive),
        AppButtonVariant.secondary => _buildSecondary(context, isActive),
        AppButtonVariant.outline => _buildOutlined(context, isActive),
        AppButtonVariant.text => _buildText(context, isActive),
        AppButtonVariant.danger => _buildDanger(context, isActive),
      },
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: AppSpacing.iconSm),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: _textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(suffixIcon, size: AppSpacing.iconSm),
        ],
      ],
    );
  }

  Widget _buildElevated(BuildContext context, bool isActive) {
    return ElevatedButton(
      onPressed: isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.neutral200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 0,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildSecondary(BuildContext context, bool isActive) {
    return ElevatedButton(
      onPressed: isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
        foregroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.neutral200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 0,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildOutlined(BuildContext context, bool isActive) {
    return OutlinedButton(
      onPressed: isActive ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.neutral300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildText(BuildContext context, bool isActive) {
    return TextButton(
      onPressed: isActive ? onPressed : null,
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      child: _buildChild(),
    );
  }

  Widget _buildDanger(BuildContext context, bool isActive) {
    return ElevatedButton(
      onPressed: isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.neutral200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 0,
      ),
      child: _buildChild(),
    );
  }
}
