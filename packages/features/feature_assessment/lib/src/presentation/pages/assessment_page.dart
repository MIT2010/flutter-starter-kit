import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assessment_bloc.dart';
import 'assessment_complete_page.dart';
import 'assessment_intro_page.dart';
import 'assessment_question_page.dart';

/// Shell yang di-routing — merender konten berbeda sesuai [AssessmentState].
/// Sengaja satu route untuk seluruh alur (intro/soal/selesai), bukan
/// beberapa go_router route terpisah, supaya AssessmentBloc yang sama
/// tetap hidup sepanjang pengerjaan tes.
class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key, required this.assessmentId});

  final String assessmentId;

  static const routePath = '/assessment/:id';

  static String path(String assessmentId) => '/assessment/$assessmentId';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AssessmentBloc, AssessmentState>(
          listener: (context, state) {
            if (state is AssessmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              AssessmentIntroReady(:final assessment) => AssessmentIntroPage(
                assessment: assessment,
              ),
              AssessmentInProgress() => AssessmentQuestionPage(state: state),
              AssessmentCompleted() => const AssessmentCompletePage(),
              AssessmentError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<AssessmentBloc>().add(
                  AssessmentLoadRequested(assessmentId: assessmentId),
                ),
              ),
              AssessmentLoading() => const AppLoading.fullScreen(),
            };
          },
        ),
      ),
    );
  }
}
