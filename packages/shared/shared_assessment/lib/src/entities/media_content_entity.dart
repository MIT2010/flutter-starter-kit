import 'package:equatable/equatable.dart';
import '../enums/assessment_enums.dart';

/// Konten media yang bisa melekat pada soal
class MediaContentEntity extends Equatable {
  const MediaContentEntity({required this.type, required this.url});

  final MediaType type;
  final String url;

  @override
  List<Object?> get props => [type, url];
}
