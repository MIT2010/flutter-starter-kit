import 'package:equatable/equatable.dart';
import 'answer_option_entity.dart';
import 'matrix_row_entity.dart';
import 'media_content_entity.dart';

/// Base sealed class untuk semua tipe soal.
///
/// Sealed class memastikan compiler mewajibkan kamu handle
/// semua tipe saat menggunakan switch expression.
/// Kalau nanti ada tipe baru, compiler akan langsung kasih tahu
/// semua tempat yang perlu diupdate.
sealed class QuestionEntity extends Equatable {
  const QuestionEntity({
    required this.id,
    required this.text,
    required this.showQuestion,
  });

  final String id;

  /// Teks pertanyaan — kosong jika showQuestion false (pertanyaan ada di media)
  final String text;

  /// false = pertanyaan hanya bisa ditemukan dari media (video/audio)
  final bool showQuestion;
}

/// Tipe 1 — Pilihan tunggal (is_multiple: 0)
class SingleChoiceQuestion extends QuestionEntity {
  const SingleChoiceQuestion({
    required super.id,
    required super.text,
    required super.showQuestion,
    required this.options,
    this.media,
  });

  final List<AnswerOptionEntity> options;
  final MediaContentEntity? media;

  @override
  List<Object?> get props => [id, text, showQuestion, options, media];
}

/// Tipe 2 — Pilihan ganda (is_multiple: 1)
class MultipleChoiceQuestion extends QuestionEntity {
  const MultipleChoiceQuestion({
    required super.id,
    required super.text,
    required super.showQuestion,
    required this.options,
    this.media,
  });

  final List<AnswerOptionEntity> options;
  final MediaContentEntity? media;

  @override
  List<Object?> get props => [id, text, showQuestion, options, media];
}

/// Tipe 3 — Matriks/grid (punya sub_items)
class MatrixQuestion extends QuestionEntity {
  const MatrixQuestion({
    required super.id,
    required super.text,
    required super.showQuestion,
    required this.rows,
    this.media,
  });

  final List<MatrixRowEntity> rows;
  final MediaContentEntity? media;

  @override
  List<Object?> get props => [id, text, showQuestion, rows, media];
}

/// Tipe 4 — Jawaban teks bebas (jawaban & sub_items null)
class OpenEndedQuestion extends QuestionEntity {
  const OpenEndedQuestion({
    required super.id,
    required super.text,
    required super.showQuestion,
    this.media,
  });

  final MediaContentEntity? media;

  @override
  List<Object?> get props => [id, text, showQuestion, media];
}
