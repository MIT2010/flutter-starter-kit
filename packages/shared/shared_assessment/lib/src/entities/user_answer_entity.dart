import 'package:equatable/equatable.dart';

/// Base sealed class untuk jawaban user
sealed class UserAnswerEntity extends Equatable {
  const UserAnswerEntity({required this.questionId, required this.answeredAt});

  final String questionId;
  final DateTime answeredAt;
}

/// Jawaban untuk SingleChoiceQuestion
class SingleChoiceAnswer extends UserAnswerEntity {
  const SingleChoiceAnswer({
    required super.questionId,
    required super.answeredAt,
    required this.selectedOptionId,
  });

  final String selectedOptionId;

  @override
  List<Object?> get props => [questionId, answeredAt, selectedOptionId];
}

/// Jawaban untuk MultipleChoiceQuestion
class MultipleChoiceAnswer extends UserAnswerEntity {
  const MultipleChoiceAnswer({
    required super.questionId,
    required super.answeredAt,
    required this.selectedOptionIds,
  });

  final List<String> selectedOptionIds;

  @override
  List<Object?> get props => [questionId, answeredAt, selectedOptionIds];
}

/// Jawaban untuk MatrixQuestion
/// key = sub_id (MatrixRowEntity.id), value = jawaban_id yang dipilih
class MatrixAnswer extends UserAnswerEntity {
  const MatrixAnswer({
    required super.questionId,
    required super.answeredAt,
    required this.selections,
  });

  final Map<String, String> selections;

  @override
  List<Object?> get props => [questionId, answeredAt, selections];
}

/// Jawaban untuk OpenEndedQuestion
class OpenEndedAnswer extends UserAnswerEntity {
  const OpenEndedAnswer({
    required super.questionId,
    required super.answeredAt,
    required this.text,
  });

  final String text;

  @override
  List<Object?> get props => [questionId, answeredAt, text];
}
