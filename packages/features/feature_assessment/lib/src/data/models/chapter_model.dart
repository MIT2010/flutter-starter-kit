import 'package:shared_assessment/shared_assessment.dart';
import '../mappers/content_mapper.dart';
import '../mappers/question_mapper.dart';

class ChapterModel {
  const ChapterModel({
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
  final Duration? timeLimit;

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => questionFromJson(q as Map<String, dynamic>))
          .toList(),
      intro: contentFromJson(json['intro'] as Map<String, dynamic>?),
      instruksi: contentFromJson(json['instruksi'] as Map<String, dynamic>?),
      timeLimit: json['time_limit_seconds'] != null
          ? Duration(seconds: json['time_limit_seconds'] as int)
          : null,
    );
  }

  ChapterEntity toEntity() {
    return ChapterEntity(
      id: id,
      title: title,
      questions: questions,
      intro: intro,
      instruksi: instruksi,
      timeLimit: timeLimit,
    );
  }
}
