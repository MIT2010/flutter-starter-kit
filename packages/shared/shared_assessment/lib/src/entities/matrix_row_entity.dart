import 'package:equatable/equatable.dart';
import 'answer_option_entity.dart';

/// Satu baris dalam soal matriks/grid
/// Contoh: "Rasa ingin tahu" dengan pilihan 1-5
class MatrixRowEntity extends Equatable {
  const MatrixRowEntity({
    required this.id,
    required this.label,
    required this.options,
  });

  final String id;
  final String label;
  final List<AnswerOptionEntity> options;

  @override
  List<Object?> get props => [id, label, options];
}
