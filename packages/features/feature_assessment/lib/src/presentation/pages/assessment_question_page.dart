import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assessment_bloc.dart';
import '../widgets/question_answer_view.dart';

class AssessmentQuestionPage extends StatelessWidget {
  const AssessmentQuestionPage({super.key, required this.state});

  final AssessmentInProgress state;

  @override
  Widget build(BuildContext context) {
    final currentAnswer = state.session.getAnswer(state.currentQuestion.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: AppText.labelMd(
            '${context.t.assessment.question} ${state.questionIndex + 1} '
            '${context.t.common.from} ${state.totalQuestions}',
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.headingMd(state.currentQuestion.text),
                const SizedBox(height: AppSpacing.lg),
                QuestionAnswerView(
                  question: state.currentQuestion,
                  answer: currentAnswer,
                  onAnswered: (answer) => context.read<AssessmentBloc>().add(
                    AssessmentAnswerSubmitted(answer),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Row(
            children: [
              if (!state.isFirstQuestion)
                Expanded(
                  child: AppButton(
                    label: context.t.common.back,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.read<AssessmentBloc>().add(
                      const AssessmentPreviousQuestionRequested(),
                    ),
                  ),
                ),
              if (!state.isFirstQuestion) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: state.isLastQuestion
                      ? context.t.assessment.submitTest
                      : context.t.common.next,
                  onPressed: currentAnswer == null
                      ? null
                      : () => context.read<AssessmentBloc>().add(
                          state.isLastQuestion
                              ? const AssessmentCompleteRequested()
                              : const AssessmentNextQuestionRequested(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
