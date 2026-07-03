import 'package:equatable/equatable.dart';
import 'assessment_content_entity.dart';
import 'question_entity.dart';

/// Bab/section dalam satu tes
class ChapterEntity extends Equatable {
  const ChapterEntity({
    required this.id,
    required this.title,
    required this.questions,
    this.intro,
    this.instruksi,
    this.timeLimit,
  });

  final String id;
  final String title;
  final List<QuestionEntity> questions;
  final AssessmentContentEntity? intro;
  final AssessmentContentEntity? instruksi;

  /// null = tidak ada timer untuk bab ini
  final Duration? timeLimit;

  bool get hasTimer => timeLimit != null;

  @override
  List<Object?> get props => [
    id,
    title,
    questions,
    intro,
    instruksi,
    timeLimit,
  ];
}
