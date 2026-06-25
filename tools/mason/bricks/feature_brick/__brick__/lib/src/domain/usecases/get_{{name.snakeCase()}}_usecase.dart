import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import '../entities/{{name.snakeCase()}}_entity.dart';
import '../repositories/{{name.snakeCase()}}_repository.dart';

class Get{{name.pascalCase()}}UseCase {
  const Get{{name.pascalCase()}}UseCase(this._repository);

  final {{name.pascalCase()}}Repository _repository;

  FutureEither<{{name.pascalCase()}}Entity> call(Get{{name.pascalCase()}}Params params) {
    return _repository.get{{name.pascalCase()}}(params.id);
  }
}

class Get{{name.pascalCase()}}Params extends Equatable {
  const Get{{name.pascalCase()}}Params({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
