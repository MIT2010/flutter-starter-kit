part of 'assessment_bloc.dart';

sealed class AssessmentState extends Equatable {
  const AssessmentState();

  @override
  List<Object?> get props => [];
}

final class AssessmentLoading extends AssessmentState {}

/// Konten assessment sudah dimuat, belum ada sesi berjalan — tampilkan
/// intro/instruksi dan tombol "Mulai Tes".
final class AssessmentIntroReady extends AssessmentState {
  const AssessmentIntroReady(this.assessment);

  final AssessmentEntity assessment;

  @override
  List<Object?> get props => [assessment];
}

/// Sedang mengerjakan tes — baik baru mulai maupun hasil resume.
final class AssessmentInProgress extends AssessmentState {
  const AssessmentInProgress({
    required this.assessment,
    required this.session,
    required this.currentQuestion,
    required this.questionIndex,
    required this.totalQuestions,
  });

  final AssessmentEntity assessment;
  final AssessmentSessionEntity session;
  final QuestionEntity currentQuestion;

  /// 0-based
  final int questionIndex;
  final int totalQuestions;

  bool get isFirstQuestion => questionIndex <= 0;
  bool get isLastQuestion => questionIndex >= totalQuestions - 1;

  @override
  List<Object?> get props => [
    assessment,
    session,
    currentQuestion,
    questionIndex,
    totalQuestions,
  ];
}

final class AssessmentCompleted extends AssessmentState {
  const AssessmentCompleted(this.session);

  final AssessmentSessionEntity session;

  @override
  List<Object?> get props => [session];
}

final class AssessmentError extends AssessmentState {
  const AssessmentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
