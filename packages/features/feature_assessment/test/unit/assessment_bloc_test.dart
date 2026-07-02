import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_assessment/feature_assessment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_assessment/shared_assessment.dart';

import 'assessment_bloc_test.mocks.dart';

@GenerateMocks([
  GetAssessmentUseCase,
  StartAssessmentSessionUseCase,
  GetActiveSessionUseCase,
  SaveSessionProgressUseCase,
  SubmitAnswerUseCase,
  CompleteAssessmentSessionUseCase,
])
void main() {
  late AssessmentBloc bloc;
  late MockGetAssessmentUseCase mockGetAssessment;
  late MockStartAssessmentSessionUseCase mockStartSession;
  late MockGetActiveSessionUseCase mockGetActiveSession;
  late MockSaveSessionProgressUseCase mockSaveProgress;
  late MockSubmitAnswerUseCase mockSubmitAnswer;
  late MockCompleteAssessmentSessionUseCase mockCompleteSession;

  const tQuestion1 = SingleChoiceQuestion(
    id: 'q1',
    text: 'Pertanyaan 1',
    showQuestion: true,
    options: [
      AnswerOptionEntity(id: 'opt-a', text: 'A'),
      AnswerOptionEntity(id: 'opt-b', text: 'B'),
    ],
  );
  const tQuestion2 = OpenEndedQuestion(
    id: 'q2',
    text: 'Pertanyaan 2',
    showQuestion: true,
  );
  const tChapter = ChapterEntity(
    id: 'chapter-1',
    title: 'Bab 1',
    questions: [tQuestion1, tQuestion2],
  );
  const tAssessment = AssessmentEntity(
    id: 'assessment-1',
    title: 'Tes Kepribadian',
    chapters: [tChapter],
  );
  final tSession = AssessmentSessionEntity(
    sessionId: 'session-1',
    assessmentId: 'assessment-1',
    startedAt: DateTime(2026),
    currentChapterId: 'chapter-1',
    currentQuestionId: 'q1',
    answers: const [],
    chapterTimeRemaining: const {},
    status: SessionStatus.inProgress,
  );

  AssessmentInProgress inProgressAt(
    QuestionEntity question,
    int index, {
    AssessmentSessionEntity? session,
  }) {
    return AssessmentInProgress(
      assessment: tAssessment,
      session: session ?? tSession,
      currentQuestion: question,
      questionIndex: index,
      totalQuestions: 2,
    );
  }

  setUp(() {
    mockGetAssessment = MockGetAssessmentUseCase();
    mockStartSession = MockStartAssessmentSessionUseCase();
    mockGetActiveSession = MockGetActiveSessionUseCase();
    mockSaveProgress = MockSaveSessionProgressUseCase();
    mockSubmitAnswer = MockSubmitAnswerUseCase();
    mockCompleteSession = MockCompleteAssessmentSessionUseCase();

    provideDummy<Either<Failure, AssessmentEntity>>(Either.right(tAssessment));
    provideDummy<Either<Failure, AssessmentSessionEntity>>(
      Either.right(tSession),
    );
    provideDummy<Either<Failure, AssessmentSessionEntity?>>(Either.right(null));
    provideDummy<Either<Failure, Unit>>(Either.right(unit));

    when(
      mockGetAssessment(any),
    ).thenAnswer((_) async => Either.right(tAssessment));
    when(mockGetActiveSession()).thenAnswer((_) async => Either.right(null));
    when(mockSaveProgress(any)).thenAnswer((_) async => Either.right(unit));
    when(
      mockSubmitAnswer(
        sessionId: anyNamed('sessionId'),
        answer: anyNamed('answer'),
      ),
    ).thenAnswer((_) async {});

    bloc = AssessmentBloc(
      getAssessment: mockGetAssessment,
      startSession: mockStartSession,
      getActiveSession: mockGetActiveSession,
      saveProgress: mockSaveProgress,
      submitAnswer: mockSubmitAnswer,
      completeSession: mockCompleteSession,
    );
  });

  tearDown(() => bloc.close());

  group('AssessmentLoadRequested', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'emit [Loading, IntroReady] saat tidak ada sesi aktif',
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const AssessmentLoadRequested(assessmentId: 'assessment-1')),
      expect: () => [
        AssessmentLoading(),
        const AssessmentIntroReady(tAssessment),
      ],
    );

    blocTest<AssessmentBloc, AssessmentState>(
      'langsung masuk InProgress saat ada sesi aktif yang cocok (resume)',
      build: () {
        when(
          mockGetActiveSession(),
        ).thenAnswer((_) async => Either.right(tSession));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const AssessmentLoadRequested(assessmentId: 'assessment-1')),
      expect: () => [AssessmentLoading(), inProgressAt(tQuestion1, 0)],
    );
  });

  group('AssessmentStartRequested', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'memulai sesi baru dan masuk ke soal pertama setelah assessment dimuat',
      build: () {
        when(
          mockStartSession('assessment-1'),
        ).thenAnswer((_) async => Either.right(tSession));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const AssessmentLoadRequested(assessmentId: 'assessment-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AssessmentStartRequested());
      },
      skip: 2, // Loading, IntroReady dari AssessmentLoadRequested
      expect: () => [AssessmentLoading(), inProgressAt(tQuestion1, 0)],
    );
  });

  group('AssessmentAnswerSubmitted', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'menyimpan jawaban dan meneruskan ke SubmitAnswerUseCase',
      build: () => bloc,
      seed: () => inProgressAt(tQuestion1, 0),
      act: (bloc) => bloc.add(
        AssessmentAnswerSubmitted(
          SingleChoiceAnswer(
            questionId: 'q1',
            answeredAt: DateTime(2026),
            selectedOptionId: 'opt-a',
          ),
        ),
      ),
      expect: () => [
        isA<AssessmentInProgress>().having(
          (s) => s.session.isAnswered('q1'),
          'session.isAnswered(q1)',
          true,
        ),
      ],
      verify: (_) {
        verify(
          mockSubmitAnswer(sessionId: 'session-1', answer: anyNamed('answer')),
        );
      },
    );
  });

  group('AssessmentNextQuestionRequested', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'pindah ke soal berikutnya',
      build: () => bloc,
      seed: () => inProgressAt(tQuestion1, 0),
      act: (bloc) => bloc.add(const AssessmentNextQuestionRequested()),
      expect: () => [
        inProgressAt(
          tQuestion2,
          1,
          session: tSession.copyWith(
            currentQuestionId: 'q2',
            currentChapterId: 'chapter-1',
          ),
        ),
      ],
    );

    blocTest<AssessmentBloc, AssessmentState>(
      'tidak melakukan apa pun di soal terakhir',
      build: () => bloc,
      seed: () => inProgressAt(
        tQuestion2,
        1,
        session: tSession.copyWith(currentQuestionId: 'q2'),
      ),
      act: (bloc) => bloc.add(const AssessmentNextQuestionRequested()),
      expect: () => [],
    );
  });

  group('AssessmentPreviousQuestionRequested', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'kembali ke soal sebelumnya',
      build: () => bloc,
      seed: () => inProgressAt(
        tQuestion2,
        1,
        session: tSession.copyWith(currentQuestionId: 'q2'),
      ),
      act: (bloc) => bloc.add(const AssessmentPreviousQuestionRequested()),
      expect: () => [inProgressAt(tQuestion1, 0)],
    );

    blocTest<AssessmentBloc, AssessmentState>(
      'tidak melakukan apa pun di soal pertama',
      build: () => bloc,
      seed: () => inProgressAt(tQuestion1, 0),
      act: (bloc) => bloc.add(const AssessmentPreviousQuestionRequested()),
      expect: () => [],
    );
  });

  group('AssessmentCompleteRequested', () {
    blocTest<AssessmentBloc, AssessmentState>(
      'emit [Loading, Completed] saat berhasil',
      build: () {
        when(
          mockCompleteSession('session-1'),
        ).thenAnswer((_) async => Either.right(unit));
        return bloc;
      },
      seed: () => inProgressAt(tQuestion2, 1),
      act: (bloc) => bloc.add(const AssessmentCompleteRequested()),
      expect: () => [AssessmentLoading(), isA<AssessmentCompleted>()],
    );

    blocTest<AssessmentBloc, AssessmentState>(
      'emit [Loading, Error] saat gagal',
      build: () {
        when(
          mockCompleteSession('session-1'),
        ).thenAnswer((_) async => Either.left(const NetworkFailure()));
        return bloc;
      },
      seed: () => inProgressAt(tQuestion2, 1),
      act: (bloc) => bloc.add(const AssessmentCompleteRequested()),
      expect: () => [
        AssessmentLoading(),
        const AssessmentError('Tidak ada koneksi internet'),
      ],
    );
  });
}
