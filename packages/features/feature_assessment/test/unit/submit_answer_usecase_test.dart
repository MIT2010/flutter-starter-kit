import 'package:feature_assessment/feature_assessment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_assessment/shared_assessment.dart';

import 'submit_answer_usecase_test.mocks.dart';

@GenerateMocks([AnswerSubmissionService])
void main() {
  late SubmitAnswerUseCase useCase;
  late MockAnswerSubmissionService mockService;

  setUp(() {
    mockService = MockAnswerSubmissionService();
    useCase = SubmitAnswerUseCase(mockService);

    when(
      mockService.submitChoiceAnswer(
        sessionId: anyNamed('sessionId'),
        questionId: anyNamed('questionId'),
        answerType: anyNamed('answerType'),
        selectedOptionIds: anyNamed('selectedOptionIds'),
      ),
    ).thenAnswer((_) async {});
    when(
      mockService.submitMatrixAnswer(
        sessionId: anyNamed('sessionId'),
        questionId: anyNamed('questionId'),
        selections: anyNamed('selections'),
      ),
    ).thenAnswer((_) async {});
    when(
      mockService.submitOpenEndedAnswer(
        sessionId: anyNamed('sessionId'),
        questionId: anyNamed('questionId'),
        text: anyNamed('text'),
      ),
    ).thenAnswer((_) async {});
  });

  test(
    'SingleChoiceAnswer diteruskan ke submitChoiceAnswer dengan tipe single_choice',
    () async {
      await useCase(
        sessionId: 'session-1',
        answer: SingleChoiceAnswer(
          questionId: 'q1',
          answeredAt: DateTime(2026),
          selectedOptionId: 'opt-a',
        ),
      );

      verify(
        mockService.submitChoiceAnswer(
          sessionId: 'session-1',
          questionId: 'q1',
          answerType: 'single_choice',
          selectedOptionIds: 'opt-a',
        ),
      );
    },
  );

  test(
    'MultipleChoiceAnswer diteruskan ke submitChoiceAnswer dengan tipe multiple_choice',
    () async {
      await useCase(
        sessionId: 'session-1',
        answer: MultipleChoiceAnswer(
          questionId: 'q2',
          answeredAt: DateTime(2026),
          selectedOptionIds: const ['opt-a', 'opt-b'],
        ),
      );

      verify(
        mockService.submitChoiceAnswer(
          sessionId: 'session-1',
          questionId: 'q2',
          answerType: 'multiple_choice',
          selectedOptionIds: ['opt-a', 'opt-b'],
        ),
      );
    },
  );

  test('MatrixAnswer diteruskan ke submitMatrixAnswer', () async {
    await useCase(
      sessionId: 'session-1',
      answer: MatrixAnswer(
        questionId: 'q3',
        answeredAt: DateTime(2026),
        selections: const {'row-1': 'opt-a'},
      ),
    );

    verify(
      mockService.submitMatrixAnswer(
        sessionId: 'session-1',
        questionId: 'q3',
        selections: {'row-1': 'opt-a'},
      ),
    );
  });

  test('OpenEndedAnswer diteruskan ke submitOpenEndedAnswer', () async {
    await useCase(
      sessionId: 'session-1',
      answer: OpenEndedAnswer(
        questionId: 'q4',
        answeredAt: DateTime(2026),
        text: 'Jawaban bebas',
      ),
    );

    verify(
      mockService.submitOpenEndedAnswer(
        sessionId: 'session-1',
        questionId: 'q4',
        text: 'Jawaban bebas',
      ),
    );
  });
}
