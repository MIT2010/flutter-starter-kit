import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../bloc/assessment_bloc.dart';

class AssessmentIntroPage extends StatelessWidget {
  const AssessmentIntroPage({super.key, required this.assessment});

  final AssessmentEntity assessment;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          AppText.headingLg(assessment.title),
          const SizedBox(height: AppSpacing.md),
          if (assessment.intro != null) ...[
            AppText.bodyMd(assessment.intro!.text),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (assessment.instruksi != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelLg(context.t.assessment.instructions),
                  const SizedBox(height: AppSpacing.sm),
                  AppText.bodyMd(assessment.instruksi!.text),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: context.t.assessment.startTest,
            onPressed: () => context.read<AssessmentBloc>().add(
              const AssessmentStartRequested(),
            ),
          ),
        ],
      ),
    );
  }
}
