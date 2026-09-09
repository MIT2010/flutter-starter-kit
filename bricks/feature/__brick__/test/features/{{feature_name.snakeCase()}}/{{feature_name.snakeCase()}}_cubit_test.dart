import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_model.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/presentation/cubit/{{feature_name.snakeCase()}}_cubit.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/presentation/cubit/{{feature_name.snakeCase()}}_state.dart';

class _MockRepository extends Mock implements {{feature_name.pascalCase()}}Repository {}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
  });

  test('initial state is {{feature_name.pascalCase()}}Initial', () {
    expect({{feature_name.pascalCase()}}Cubit(repository).state, const {{feature_name.pascalCase()}}State.initial());
  });

  const item = {{feature_name.pascalCase()}}Item(message: 'test message');

  blocTest<{{feature_name.pascalCase()}}Cubit, {{feature_name.pascalCase()}}State>(
    'emits [loading, loaded] on a successful Result',
    build: () {
      when(() => repository.getData()).thenAnswer((_) async => const Result.success(item));
      return {{feature_name.pascalCase()}}Cubit(repository);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      const {{feature_name.pascalCase()}}State.loading(),
      const {{feature_name.pascalCase()}}State.loaded(item),
    ],
  );

  blocTest<{{feature_name.pascalCase()}}Cubit, {{feature_name.pascalCase()}}State>(
    'emits [loading, error] on a failed Result',
    build: () {
      when(() => repository.getData()).thenAnswer((_) async => const Result.failure(ServerFailure()));
      return {{feature_name.pascalCase()}}Cubit(repository);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      const {{feature_name.pascalCase()}}State.loading(),
      const {{feature_name.pascalCase()}}State.error(ServerFailure()),
    ],
  );
}
