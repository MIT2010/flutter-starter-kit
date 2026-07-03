import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';

/// Error view yang konsisten di seluruh aplikasi.
///
/// `title` wajib diisi (bukan default hardcoded) supaya teks selalu lewat
/// `core_l10n` di pemanggil — `core_ui` sendiri tidak bergantung ke paket
/// l10n manapun, jadi tidak boleh ada teks berbahasa tertentu yang
/// ke-hardcode di sini (sebelumnya default 'Terjadi Kesalahan'/'Coba Lagi'
/// selalu muncul dalam Bahasa Indonesia meski locale aktif English).
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: AppSpacing.iconXl,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headingSm.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && retryLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: retryLabel!,
                onPressed: onRetry,
                variant: AppButtonVariant.outline,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
