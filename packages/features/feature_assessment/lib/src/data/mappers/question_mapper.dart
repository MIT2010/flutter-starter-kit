import 'package:shared_assessment/shared_assessment.dart';

/// Konversi JSON dari API menjadi salah satu varian sealed [QuestionEntity].
/// Tidak ada QuestionModel terpisah — entity-nya sendiri sudah cukup sebagai
/// data holder, jadi mapper ini langsung menghasilkan entity.
QuestionEntity questionFromJson(Map<String, dynamic> json) {
  final id = json['id'] as String;
  final text = json['text'] as String? ?? '';
  final showQuestion = json['show_question'] as bool? ?? true;
  final media = _mediaFromJson(json['media'] as Map<String, dynamic>?);

  return switch (json['type'] as String) {
    'single_choice' => SingleChoiceQuestion(
      id: id,
      text: text,
      showQuestion: showQuestion,
      options: _optionsFromJson(json['options'] as List),
      media: media,
    ),
    'multiple_choice' => MultipleChoiceQuestion(
      id: id,
      text: text,
      showQuestion: showQuestion,
      options: _optionsFromJson(json['options'] as List),
      media: media,
    ),
    'matrix' => MatrixQuestion(
      id: id,
      text: text,
      showQuestion: showQuestion,
      rows: (json['rows'] as List)
          .map((row) => _rowFromJson(row as Map<String, dynamic>))
          .toList(),
      media: media,
    ),
    'open_ended' => OpenEndedQuestion(
      id: id,
      text: text,
      showQuestion: showQuestion,
      media: media,
    ),
    final type => throw FormatException('Tipe soal tidak dikenal: $type'),
  };
}

List<AnswerOptionEntity> _optionsFromJson(List<dynamic> raw) {
  return raw
      .map((e) => e as Map<String, dynamic>)
      .map(
        (json) => AnswerOptionEntity(
          id: json['id'] as String,
          text: json['text'] as String,
        ),
      )
      .toList();
}

MatrixRowEntity _rowFromJson(Map<String, dynamic> json) {
  return MatrixRowEntity(
    id: json['id'] as String,
    label: json['label'] as String,
    options: _optionsFromJson(json['options'] as List),
  );
}

MediaContentEntity? _mediaFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return MediaContentEntity(
    type: MediaType.values.byName(json['type'] as String),
    url: json['url'] as String,
  );
}
