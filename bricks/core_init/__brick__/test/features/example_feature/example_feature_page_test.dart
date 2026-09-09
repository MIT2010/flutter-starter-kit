import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/app/di.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/features/example_feature/data/models/example_item_model.dart';
import 'package:{{project_name}}/features/example_feature/domain/repositories/example_feature_repository.dart';
import 'package:{{project_name}}/features/example_feature/presentation/cubit/example_feature_cubit.dart';
import 'package:{{project_name}}/features/example_feature/presentation/pages/example_feature_page.dart';

class _MockExampleFeatureRepository extends Mock
    implements ExampleFeatureRepository {}

const _item = ExampleItem(
  id: 1,
  title: 'A sample title',
  body: 'A sample body for the example feature screen.',
);

void main() {
  late _MockExampleFeatureRepository repository;

  setUp(() {
    repository = _MockExampleFeatureRepository();
    getIt.registerFactory<ExampleFeatureCubit>(
      () => ExampleFeatureCubit(repository),
    );
  });

  tearDown(() => getIt.reset());

  testWidgets('shows a loading indicator, then the fetched content', (
    tester,
  ) async {
    when(
      () => repository.getExampleItem(),
    ).thenAnswer((_) async => const Result.success(_item));

    await tester.pumpWidget(const MaterialApp(home: ExampleFeaturePage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('A sample title'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows the failure message and a retry button on error', (
    tester,
  ) async {
    when(
      () => repository.getExampleItem(),
    ).thenAnswer((_) async => const Result.failure(ServerFailure()));

    await tester.pumpWidget(const MaterialApp(home: ExampleFeaturePage()));
    await tester.pumpAndSettle();

    expect(find.text(const ServerFailure().message), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('retry button re-fetches after a failure', (tester) async {
    var callCount = 0;
    when(() => repository.getExampleItem()).thenAnswer((_) async {
      callCount++;
      return callCount == 1
          ? const Result.failure(ServerFailure())
          : const Result.success(_item);
    });

    await tester.pumpWidget(const MaterialApp(home: ExampleFeaturePage()));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('A sample title'), findsOneWidget);
    expect(callCount, 2);
  });

  testWidgets('golden: loaded state matches the reference screenshot', (
    tester,
  ) async {
    when(
      () => repository.getExampleItem(),
    ).thenAnswer((_) async => const Result.success(_item));

    await tester.pumpWidget(const MaterialApp(home: ExampleFeaturePage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ExampleFeaturePage),
      matchesGoldenFile('goldens/example_feature_page_loaded.png'),
    );
  });
}
