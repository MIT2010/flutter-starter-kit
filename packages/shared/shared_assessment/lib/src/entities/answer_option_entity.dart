import 'package:equatable/equatable.dart';

/// Satu pilihan jawaban
class AnswerOptionEntity extends Equatable {
  const AnswerOptionEntity({required this.id, required this.text});

  final String id;
  final String text;

  @override
  List<Object?> get props => [id, text];
}
