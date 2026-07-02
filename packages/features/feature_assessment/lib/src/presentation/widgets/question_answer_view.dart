import 'package:flutter/widgets.dart';
import 'package:shared_assessment/shared_assessment.dart';
import 'matrix_answer_widget.dart';
import 'multiple_choice_answer_widget.dart';
import 'open_ended_answer_widget.dart';
import 'single_choice_answer_widget.dart';

/// Dispatcher yang merender widget jawaban sesuai varian sealed
/// [QuestionEntity]. Switch di bawah ini exhaustive — kalau ada tipe soal
/// baru ditambahkan ke shared_assessment, compiler akan menandai baris ini
/// butuh diupdate.
class QuestionAnswerView extends StatelessWidget {
  const QuestionAnswerView({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswered,
  });

  final QuestionEntity question;
  final UserAnswerEntity? answer;
  final ValueChanged<UserAnswerEntity> onAnswered;

  @override
  Widget build(BuildContext context) {
    // Promosi tipe dari switch pattern hanya berlaku untuk local variable,
    // bukan field publik seperti `question` — lihat http://dart.dev/go/non-promo-public-field.
    final q = question;

    return switch (q) {
      SingleChoiceQuestion() => SingleChoiceAnswerWidget(
        key: ValueKey(q.id),
        question: q,
        answer: answer as SingleChoiceAnswer?,
        onChanged: (optionId) => onAnswered(
          SingleChoiceAnswer(
            questionId: q.id,
            answeredAt: DateTime.now(),
            selectedOptionId: optionId,
          ),
        ),
      ),
      MultipleChoiceQuestion() => MultipleChoiceAnswerWidget(
        key: ValueKey(q.id),
        question: q,
        answer: answer as MultipleChoiceAnswer?,
        onChanged: (optionIds) => onAnswered(
          MultipleChoiceAnswer(
            questionId: q.id,
            answeredAt: DateTime.now(),
            selectedOptionIds: optionIds,
          ),
        ),
      ),
      MatrixQuestion() => MatrixAnswerWidget(
        key: ValueKey(q.id),
        question: q,
        answer: answer as MatrixAnswer?,
        onChanged: (selections) => onAnswered(
          MatrixAnswer(
            questionId: q.id,
            answeredAt: DateTime.now(),
            selections: selections,
          ),
        ),
      ),
      OpenEndedQuestion() => OpenEndedAnswerWidget(
        key: ValueKey(q.id),
        question: q,
        answer: answer as OpenEndedAnswer?,
        onChanged: (text) => onAnswered(
          OpenEndedAnswer(
            questionId: q.id,
            answeredAt: DateTime.now(),
            text: text,
          ),
        ),
      ),
    };
  }
}
