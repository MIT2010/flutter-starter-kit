import 'package:shared_assessment/shared_assessment.dart';
import '../mappers/answer_mapper.dart';

/// Model dua-arah: dibaca dari response server (fromJson) maupun dari
/// cache lokal (fromJson juga, karena disimpan sebagai JSON string yang
/// sama), dan ditulis ke cache lokal (toJson).
class AssessmentSessionModel {
  const AssessmentSessionModel({
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
  final String currentChapterId;
  final String currentQuestionId;
  final List<UserAnswerEntity> answers;
  final Map<String, int> chapterTimeRemaining;

  factory AssessmentSessionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentSessionModel(
      sessionId: json['session_id'] as String,
      assessmentId: json['assessment_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: SessionStatus.values.byName(json['status'] as String),
      currentChapterId: json['current_chapter_id'] as String,
      currentQuestionId: json['current_question_id'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((a) => answerFromJson(a as Map<String, dynamic>))
          .toList(),
      chapterTimeRemaining:
          (json['chapter_time_remaining'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as int),
          ),
    );
  }

  factory AssessmentSessionModel.fromEntity(AssessmentSessionEntity entity) {
    return AssessmentSessionModel(
      sessionId: entity.sessionId,
      assessmentId: entity.assessmentId,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      status: entity.status,
      currentChapterId: entity.currentChapterId,
      currentQuestionId: entity.currentQuestionId,
      answers: entity.answers,
      chapterTimeRemaining: entity.chapterTimeRemaining,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'assessment_id': assessmentId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status.name,
      'current_chapter_id': currentChapterId,
      'current_question_id': currentQuestionId,
      'answers': answers.map(answerToJson).toList(),
      'chapter_time_remaining': chapterTimeRemaining,
    };
  }

  AssessmentSessionEntity toEntity() {
    return AssessmentSessionEntity(
      sessionId: sessionId,
      assessmentId: assessmentId,
      startedAt: startedAt,
      completedAt: completedAt,
      status: status,
      currentChapterId: currentChapterId,
      currentQuestionId: currentQuestionId,
      answers: answers,
      chapterTimeRemaining: chapterTimeRemaining,
    );
  }
}
