import 'package:equatable/equatable.dart';
import '../enums/assessment_enums.dart';

/// Konten teks untuk intro dan instruksi — bisa markdown atau plain text
class AssessmentContentEntity extends Equatable {
  const AssessmentContentEntity({
    required this.text,
    this.format = ContentFormat.markdown,
  });

  final String text;
  final ContentFormat format;

  @override
  List<Object?> get props => [text, format];
}
