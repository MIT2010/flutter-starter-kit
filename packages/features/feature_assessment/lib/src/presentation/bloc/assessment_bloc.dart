import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../../domain/usecases/complete_assessment_session_usecase.dart';
import '../../domain/usecases/get_active_session_usecase.dart';
import '../../domain/usecases/get_assessment_usecase.dart';
import '../../domain/usecases/save_session_progress_usecase.dart';
import '../../domain/usecases/start_assessment_session_usecase.dart';
import '../../domain/usecases/submit_answer_usecase.dart';

part 'assessment_event.dart';
part 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  AssessmentBloc({
    required GetAssessmentUseCase getAssessment,
    required StartAssessmentSessionUseCase startSession,
    required GetActiveSessionUseCase getActiveSession,
    required SaveSessionProgressUseCase saveProgress,
    required SubmitAnswerUseCase submitAnswer,
    required CompleteAssessmentSessionUseCase completeSession,
  }) : _getAssessment = getAssessment,
       _startSession = startSession,
       _getActiveSession = getActiveSession,
       _saveProgress = saveProgress,
       _submitAnswer = submitAnswer,
       _completeSession = completeSession,
       super(AssessmentLoading()) {
    on<AssessmentLoadRequested>(_onLoadRequested);
    on<AssessmentStartRequested>(_onStartRequested);
    on<AssessmentAnswerSubmitted>(_onAnswerSubmitted);
    on<AssessmentNextQuestionRequested>(_onNextQuestionRequested);
    on<AssessmentPreviousQuestionRequested>(_onPreviousQuestionRequested);
    on<AssessmentCompleteRequested>(_onCompleteRequested);
  }

  final GetAssessmentUseCase _getAssessment;
  final StartAssessmentSessionUseCase _startSession;
  final GetActiveSessionUseCase _getActiveSession;
  final SaveSessionProgressUseCase _saveProgress;
  final SubmitAnswerUseCase _submitAnswer;
  final CompleteAssessmentSessionUseCase _completeSession;

  AssessmentEntity? _assessment;

  Future<void> _onLoadRequested(
    AssessmentLoadRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(AssessmentLoading());

    final result = await _getAssessment(event.assessmentId);
    await result.fold((failure) async => emit(AssessmentError(failure.message)), (
      assessment,
    ) async {
      _assessment = assessment;

      final activeSessionResult = await _getActiveSession();
      activeSessionResult.fold(
        // Cache lokal gagal dibaca — tetap lanjut ke intro, jangan blokir user.
        (failure) => emit(AssessmentIntroReady(assessment)),
        (session) {
          final resumable =
              session != null &&
              session.assessmentId == assessment.id &&
              session.isInProgress;
          emit(
            resumable
                ? _inProgressState(assessment, session)
                : AssessmentIntroReady(assessment),
          );
        },
      );
    });
  }

  Future<void> _onStartRequested(
    AssessmentStartRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    final assessment = _assessment;
    if (assessment == null) return;

    emit(AssessmentLoading());
    final result = await _startSession(assessment.id);
    await result.fold(
      (failure) async => emit(AssessmentError(failure.message)),
      (session) async {
        final normalized = _normalizeStartingPosition(assessment, session);
        await _saveProgress(normalized);
        emit(_inProgressState(assessment, normalized));
      },
    );
  }

  Future<void> _onAnswerSubmitted(
    AssessmentAnswerSubmitted event,
    Emitter<AssessmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssessmentInProgress) return;

    final updatedAnswers = [
      ...currentState.session.answers.where(
        (a) => a.questionId != event.answer.questionId,
      ),
      event.answer,
    ];
    final updatedSession = currentState.session.copyWith(
      answers: updatedAnswers,
    );

    await _saveProgress(updatedSession);
    unawaited(
      _submitAnswer(sessionId: updatedSession.sessionId, answer: event.answer),
    );

    emit(_inProgressState(currentState.assessment, updatedSession));
  }

  Future<void> _onNextQuestionRequested(
    AssessmentNextQuestionRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssessmentInProgress || currentState.isLastQuestion) {
      return;
    }

    final questions = _navigableQuestions(currentState.assessment);
    final next = questions[currentState.questionIndex + 1];
    final updatedSession = currentState.session.copyWith(
      currentQuestionId: next.id,
      currentChapterId: _chapterIdOf(currentState.assessment, next.id),
    );

    await _saveProgress(updatedSession);
    emit(_inProgressState(currentState.assessment, updatedSession));
  }

  Future<void> _onPreviousQuestionRequested(
    AssessmentPreviousQuestionRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssessmentInProgress || currentState.isFirstQuestion) {
      return;
    }

    final questions = _navigableQuestions(currentState.assessment);
    final previous = questions[currentState.questionIndex - 1];
    final updatedSession = currentState.session.copyWith(
      currentQuestionId: previous.id,
      currentChapterId: _chapterIdOf(currentState.assessment, previous.id),
    );

    await _saveProgress(updatedSession);
    emit(_inProgressState(currentState.assessment, updatedSession));
  }

  Future<void> _onCompleteRequested(
    AssessmentCompleteRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssessmentInProgress) return;

    emit(AssessmentLoading());
    final result = await _completeSession(currentState.session.sessionId);
    result.fold(
      (failure) => emit(AssessmentError(failure.message)),
      (_) => emit(
        AssessmentCompleted(
          currentState.session.copyWith(status: SessionStatus.completed),
        ),
      ),
    );
  }

  /// Semua soal lintas bab, urut, hanya yang showQuestion == true — inilah
  /// yang dipakai untuk navigasi next/previous dan penomoran "X dari Y".
  List<QuestionEntity> _navigableQuestions(AssessmentEntity assessment) {
    return assessment.chapters
        .expand((chapter) => chapter.questions)
        .where((q) => q.showQuestion)
        .toList();
  }

  String _chapterIdOf(AssessmentEntity assessment, String questionId) {
    for (final chapter in assessment.chapters) {
      if (chapter.questions.any((q) => q.id == questionId)) {
        return chapter.id;
      }
    }
    return assessment.chapters.first.id;
  }

  /// Backend (atau stub-nya) mungkin tidak selalu mengembalikan
  /// currentQuestionId yang valid — pastikan sesi baru selalu mengarah ke
  /// soal navigable pertama.
  AssessmentSessionEntity _normalizeStartingPosition(
    AssessmentEntity assessment,
    AssessmentSessionEntity session,
  ) {
    final questions = _navigableQuestions(assessment);
    if (questions.any((q) => q.id == session.currentQuestionId)) {
      return session;
    }
    final first = questions.first;
    return session.copyWith(
      currentQuestionId: first.id,
      currentChapterId: _chapterIdOf(assessment, first.id),
    );
  }

  AssessmentInProgress _inProgressState(
    AssessmentEntity assessment,
    AssessmentSessionEntity session,
  ) {
    final questions = _navigableQuestions(assessment);
    final index = questions.indexWhere(
      (q) => q.id == session.currentQuestionId,
    );
    final safeIndex = index < 0 ? 0 : index;
    return AssessmentInProgress(
      assessment: assessment,
      session: session,
      currentQuestion: questions[safeIndex],
      questionIndex: safeIndex,
      totalQuestions: questions.length,
    );
  }
}
