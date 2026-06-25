import '../../domain/entities/{{name.snakeCase()}}_entity.dart';

class {{name.pascalCase()}}Model {
  const {{name.pascalCase()}}Model({
    required this.id,
  });

  final String id;

  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) {
    return {{name.pascalCase()}}Model(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  {{name.pascalCase()}}Entity toEntity() {
    return {{name.pascalCase()}}Entity(
      id: id,
    );
  }
}
