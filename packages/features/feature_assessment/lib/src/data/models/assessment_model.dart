import 'package:shared_assessment/shared_assessment.dart';
import '../mappers/content_mapper.dart';
import 'chapter_model.dart';

class AssessmentModel {
  const AssessmentModel({
    required this.id,
    required this.title,
    required this.chapters,
    this.intro,
    this.instruksi,
  });

  final String id;
  final String title;
  final List<ChapterModel> chapters;
  final AssessmentContentEntity? intro;
  final AssessmentContentEntity? instruksi;

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      intro: contentFromJson(json['intro'] as Map<String, dynamic>?),
      instruksi: contentFromJson(json['instruksi'] as Map<String, dynamic>?),
    );
  }

  AssessmentEntity toEntity() {
    return AssessmentEntity(
      id: id,
      title: title,
      chapters: chapters.map((c) => c.toEntity()).toList(),
      intro: intro,
      instruksi: instruksi,
    );
  }
}
