import 'package:equatable/equatable.dart';
import 'assessment_content_entity.dart';
import 'chapter_entity.dart';

/// Satu tes psikologi lengkap
class AssessmentEntity extends Equatable {
  const AssessmentEntity({
    required this.id,
    required this.title,
    required this.chapters,
    this.intro,
    this.instruksi,
  });

  final String id;
  final String title;
  final List<ChapterEntity> chapters;
  final AssessmentContentEntity? intro;
  final AssessmentContentEntity? instruksi;

  /// Total jumlah soal di semua bab
  int get totalQuestions =>
      chapters.fold(0, (sum, chapter) => sum + chapter.questions.length);

  /// Apakah ada bab yang punya timer
  bool get hasTimed => chapters.any((chapter) => chapter.hasTimer);

  @override
  List<Object?> get props => [id, title, chapters, intro, instruksi];
}
