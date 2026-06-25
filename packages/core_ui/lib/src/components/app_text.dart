import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Text component dengan style yang konsisten.
class AppText extends StatelessWidget {
  const AppText.displayLg(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.displayLg;

  const AppText.displayMd(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.displayMd;

  const AppText.headingXl(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.headingXl;

  const AppText.headingLg(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.headingLg;

  const AppText.headingMd(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.headingMd;

  const AppText.headingSm(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.headingSm;

  const AppText.bodyLg(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.bodyLg;

  const AppText.bodyMd(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.bodyMd;

  const AppText.bodySm(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.bodySm;

  const AppText.labelLg(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.labelLg;

  const AppText.labelMd(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.labelMd;

  const AppText.labelSm(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.labelSm;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  }) : _style = AppTextStyle.caption;

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final AppTextStyle _style;

  TextStyle _resolveStyle() {
    return switch (_style) {
      AppTextStyle.displayLg => AppTypography.displayLg,
      AppTextStyle.displayMd => AppTypography.displayMd,
      AppTextStyle.headingXl => AppTypography.headingXl,
      AppTextStyle.headingLg => AppTypography.headingLg,
      AppTextStyle.headingMd => AppTypography.headingMd,
      AppTextStyle.headingSm => AppTypography.headingSm,
      AppTextStyle.bodyLg => AppTypography.bodyLg,
      AppTextStyle.bodyMd => AppTypography.bodyMd,
      AppTextStyle.bodySm => AppTypography.bodySm,
      AppTextStyle.labelLg => AppTypography.labelLg,
      AppTextStyle.labelMd => AppTypography.labelMd,
      AppTextStyle.labelSm => AppTypography.labelSm,
      AppTextStyle.caption => AppTypography.caption,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _resolveStyle().copyWith(
        color: color ?? AppColors.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

enum AppTextStyle {
  displayLg,
  displayMd,
  headingXl,
  headingLg,
  headingMd,
  headingSm,
  bodyLg,
  bodyMd,
  bodySm,
  labelLg,
  labelMd,
  labelSm,
  caption,
}
