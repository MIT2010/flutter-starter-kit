import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/app/di.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_model.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/presentation/cubit/{{feature_name.snakeCase()}}_cubit.dart';
import 'package:{{project_name}}/features/{{feature_name.snakeCase()}}/presentation/pages/{{feature_name.snakeCase()}}_page.dart';

class _MockRepository extends Mock implements {{feature_name.pascalCase()}}Repository {}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    getIt.registerFactory<{{feature_name.pascalCase()}}Cubit>(() => {{feature_name.pascalCase()}}Cubit(repository));
  });

  tearDown(() => getIt.reset());

  testWidgets('shows a loading indicator, then the fetched content', (tester) async {
    when(
      () => repository.getData(),
    ).thenAnswer((_) async => const Result.success({{feature_name.pascalCase()}}Item(message: 'hello')));

    await tester.pumpWidget(const MaterialApp(home: {{feature_name.pascalCase()}}Page()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('shows the failure message and a retry button on error', (tester) async {
    when(() => repository.getData()).thenAnswer((_) async => const Result.failure(ServerFailure()));

    await tester.pumpWidget(const MaterialApp(home: {{feature_name.pascalCase()}}Page()));
    await tester.pumpAndSettle();

    expect(find.text(const ServerFailure().message), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });
}
