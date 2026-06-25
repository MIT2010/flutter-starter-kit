part of '{{name.snakeCase()}}_bloc.dart';

sealed class {{name.pascalCase()}}State extends Equatable {
  const {{name.pascalCase()}}State();

  @override
  List<Object?> get props => [];
}

final class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {}

final class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {}

final class {{name.pascalCase()}}Loaded extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Loaded(this.data);

  final {{name.pascalCase()}}Entity data;

  @override
  List<Object?> get props => [data];
}

final class {{name.pascalCase()}}Error extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Error(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
