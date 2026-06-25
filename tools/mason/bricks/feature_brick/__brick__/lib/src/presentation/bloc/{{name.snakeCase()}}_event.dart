part of '{{name.snakeCase()}}_bloc.dart';

sealed class {{name.pascalCase()}}Event extends Equatable {
  const {{name.pascalCase()}}Event();

  @override
  List<Object?> get props => [];
}

final class Load{{name.pascalCase()}}Event extends {{name.pascalCase()}}Event {
  const Load{{name.pascalCase()}}Event({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class Refresh{{name.pascalCase()}}Event extends {{name.pascalCase()}}Event {
  const Refresh{{name.pascalCase()}}Event({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
