import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssessmentCompletePage extends StatelessWidget {
  const AssessmentCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: AppSpacing.iconXl,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText.headingLg(context.t.common.finish),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.t.common.back,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
