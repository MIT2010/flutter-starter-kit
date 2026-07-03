import 'package:equatable/equatable.dart';
import '../enums/assessment_enums.dart';
import 'user_answer_entity.dart';

/// State satu sesi pengerjaan tes.
/// Disimpan ke local storage untuk mendukung resume.
class AssessmentSessionEntity extends Equatable {
  const AssessmentSessionEntity({
    required this.sessionId,
    required this.assessmentId,
    required this.startedAt,
    required this.currentChapterId,
    required this.currentQuestionId,
    required this.answers,
    required this.chapterTimeRemaining,
    required this.status,
    this.completedAt,
  });

  final String sessionId;
  final String assessmentId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final SessionStatus status;

  /// Posisi terakhir user — untuk resume
  final String currentChapterId;
  final String currentQuestionId;

  /// Semua jawaban yang sudah diisi
  final List<UserAnswerEntity> answers;

  /// Sisa waktu per bab dalam detik — key = chapterId
  final Map<String, int> chapterTimeRemaining;

  bool get isCompleted => status == SessionStatus.completed;
  bool get isInProgress => status == SessionStatus.inProgress;

  /// Cek apakah soal tertentu sudah dijawab
  bool isAnswered(String questionId) =>
      answers.any((a) => a.questionId == questionId);

  /// Ambil jawaban untuk soal tertentu
  UserAnswerEntity? getAnswer(String questionId) {
    try {
      return answers.firstWhere((a) => a.questionId == questionId);
    } catch (_) {
      return null;
    }
  }

  /// Buat salinan session dengan field yang diupdate
  AssessmentSessionEntity copyWith({
    String? currentChapterId,
    String? currentQuestionId,
    List<UserAnswerEntity>? answers,
    Map<String, int>? chapterTimeRemaining,
    SessionStatus? status,
    DateTime? completedAt,
  }) {
    return AssessmentSessionEntity(
      sessionId: sessionId,
      assessmentId: assessmentId,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      currentChapterId: currentChapterId ?? this.currentChapterId,
      currentQuestionId: currentQuestionId ?? this.currentQuestionId,
      answers: answers ?? this.answers,
      chapterTimeRemaining: chapterTimeRemaining ?? this.chapterTimeRemaining,
    );
  }

  @override
  List<Object?> get props => [
    sessionId,
    assessmentId,
    startedAt,
    completedAt,
    status,
    currentChapterId,
    currentQuestionId,
    answers,
    chapterTimeRemaining,
  ];
}
