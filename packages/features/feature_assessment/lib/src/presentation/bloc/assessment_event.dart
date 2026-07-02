part of 'assessment_bloc.dart';

sealed class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

/// Muat konten assessment + cek apakah ada sesi yang bisa di-resume.
final class AssessmentLoadRequested extends AssessmentEvent {
  const AssessmentLoadRequested({required this.assessmentId});

  final String assessmentId;

  @override
  List<Object?> get props => [assessmentId];
}

/// User menekan "Mulai Tes" dari halaman intro.
final class AssessmentStartRequested extends AssessmentEvent {
  const AssessmentStartRequested();
}

/// User mengisi/mengubah jawaban soal yang sedang tampil.
final class AssessmentAnswerSubmitted extends AssessmentEvent {
  const AssessmentAnswerSubmitted(this.answer);

  final UserAnswerEntity answer;

  @override
  List<Object?> get props => [answer];
}

final class AssessmentNextQuestionRequested extends AssessmentEvent {
  const AssessmentNextQuestionRequested();
}

final class AssessmentPreviousQuestionRequested extends AssessmentEvent {
  const AssessmentPreviousQuestionRequested();
}

/// User menekan "Kirim Jawaban" di soal terakhir.
final class AssessmentCompleteRequested extends AssessmentEvent {
  const AssessmentCompleteRequested();
}
