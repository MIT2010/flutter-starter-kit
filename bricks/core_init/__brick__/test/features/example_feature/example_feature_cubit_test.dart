import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/features/example_feature/data/models/example_item_model.dart';
import 'package:{{project_name}}/features/example_feature/domain/repositories/example_feature_repository.dart';
import 'package:{{project_name}}/features/example_feature/presentation/cubit/example_feature_cubit.dart';
import 'package:{{project_name}}/features/example_feature/presentation/cubit/example_feature_state.dart';

class _MockExampleFeatureRepository extends Mock
    implements ExampleFeatureRepository {}

void main() {
  late _MockExampleFeatureRepository repository;

  setUp(() {
    repository = _MockExampleFeatureRepository();
  });

  test('initial state is ExampleFeatureInitial', () {
    expect(
      ExampleFeatureCubit(repository).state,
      const ExampleFeatureState.initial(),
    );
  });

  const item = ExampleItem(id: 1, title: 'title', body: 'body');

  blocTest<ExampleFeatureCubit, ExampleFeatureState>(
    'emits [loading, loaded] on a successful Result',
    build: () {
      when(
        () => repository.getExampleItem(),
      ).thenAnswer((_) async => const Result.success(item));
      return ExampleFeatureCubit(repository);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      const ExampleFeatureState.loading(),
      const ExampleFeatureState.loaded(item),
    ],
  );

  blocTest<ExampleFeatureCubit, ExampleFeatureState>(
    'emits [loading, error] on a failed Result',
    build: () {
      when(
        () => repository.getExampleItem(),
      ).thenAnswer((_) async => const Result.failure(ServerFailure()));
      return ExampleFeatureCubit(repository);
    },
    act: (cubit) => cubit.fetch(),
    expect: () => [
      const ExampleFeatureState.loading(),
      const ExampleFeatureState.error(ServerFailure()),
    ],
  );
}
