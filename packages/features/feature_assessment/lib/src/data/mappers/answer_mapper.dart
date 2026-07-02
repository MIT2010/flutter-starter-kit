import 'package:shared_assessment/shared_assessment.dart';

/// Konversi JSON <-> UserAnswerEntity. Struktur field (answer_type /
/// answer_payload) sengaja sama dengan payload QueueItem yang dipakai
/// AnswerSubmissionService, supaya satu bahasa antara queue dan session cache.
UserAnswerEntity answerFromJson(Map<String, dynamic> json) {
  final questionId = json['question_id'] as String;
  final answeredAt = DateTime.parse(json['answered_at'] as String);
  final payload = json['answer_payload'] as Map<String, dynamic>;

  return switch (json['answer_type'] as String) {
    'single_choice' => SingleChoiceAnswer(
      questionId: questionId,
      answeredAt: answeredAt,
      selectedOptionId: payload['selected_option_ids'] as String,
    ),
    'multiple_choice' => MultipleChoiceAnswer(
      questionId: questionId,
      answeredAt: answeredAt,
      selectedOptionIds: (payload['selected_option_ids'] as List)
          .map((e) => e as String)
          .toList(),
    ),
    'matrix' => MatrixAnswer(
      questionId: questionId,
      answeredAt: answeredAt,
      selections: (payload['selections'] as Map).map(
        (key, value) => MapEntry(key as String, value as String),
      ),
    ),
    'open_ended' => OpenEndedAnswer(
      questionId: questionId,
      answeredAt: answeredAt,
      text: payload['text'] as String,
    ),
    final type => throw FormatException('Tipe jawaban tidak dikenal: $type'),
  };
}

Map<String, dynamic> answerToJson(UserAnswerEntity answer) {
  final (answerType, payload) = switch (answer) {
    SingleChoiceAnswer(:final selectedOptionId) => (
      'single_choice',
      {'selected_option_ids': selectedOptionId},
    ),
    MultipleChoiceAnswer(:final selectedOptionIds) => (
      'multiple_choice',
      {'selected_option_ids': selectedOptionIds},
    ),
    MatrixAnswer(:final selections) => ('matrix', {'selections': selections}),
    OpenEndedAnswer(:final text) => ('open_ended', {'text': text}),
  };

  return {
    'question_id': answer.questionId,
    'answered_at': answer.answeredAt.toIso8601String(),
    'answer_type': answerType,
    'answer_payload': payload,
  };
}
