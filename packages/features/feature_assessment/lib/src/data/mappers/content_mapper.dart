import 'package:shared_assessment/shared_assessment.dart';

/// Konversi JSON menjadi [AssessmentContentEntity] — dipakai untuk field
/// intro/instruksi di AssessmentModel maupun ChapterModel.
AssessmentContentEntity? contentFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return AssessmentContentEntity(
    text: json['text'] as String,
    format: ContentFormat.values.byName(
      json['format'] as String? ?? 'markdown',
    ),
  );
}
