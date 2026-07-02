import 'package:shared_assessment/shared_assessment.dart';
import '../../queue/answer_submission_service.dart';

/// Wrapper tipis di atas AnswerSubmissionService supaya presentation layer
/// tidak perlu tahu soal queue offline — cukup panggil use case ini.
///
/// Sengaja tidak mengembalikan FutureEither seperti use case lain: dari
/// sudut pandang pemanggil, "submit" selalu berhasil (masuk antrian).
/// Kegagalan kirim ke server ditangani penuh oleh queue (retry otomatis),
/// bukan tanggung jawab use case ini.
class SubmitAnswerUseCase {
  const SubmitAnswerUseCase(this._submissionService);

  final AnswerSubmissionService _submissionService;

  Future<void> call({
    required String sessionId,
    required UserAnswerEntity answer,
  }) {
    return switch (answer) {
      SingleChoiceAnswer(:final selectedOptionId) =>
        _submissionService.submitChoiceAnswer(
          sessionId: sessionId,
          questionId: answer.questionId,
          answerType: 'single_choice',
          selectedOptionIds: selectedOptionId,
        ),
      MultipleChoiceAnswer(:final selectedOptionIds) =>
        _submissionService.submitChoiceAnswer(
          sessionId: sessionId,
          questionId: answer.questionId,
          answerType: 'multiple_choice',
          selectedOptionIds: selectedOptionIds,
        ),
      MatrixAnswer(:final selections) => _submissionService.submitMatrixAnswer(
        sessionId: sessionId,
        questionId: answer.questionId,
        selections: selections,
      ),
      OpenEndedAnswer(:final text) => _submissionService.submitOpenEndedAnswer(
        sessionId: sessionId,
        questionId: answer.questionId,
        text: text,
      ),
    };
  }
}
