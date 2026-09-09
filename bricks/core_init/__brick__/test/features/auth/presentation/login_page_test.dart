import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/app/auth_status_notifier.dart';
import 'package:{{project_name}}/app/di.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/core/storage/hive_client.dart';
import 'package:{{project_name}}/features/auth/data/models/auth_user_model.dart';
import 'package:{{project_name}}/features/auth/domain/repositories/auth_repository.dart';
import 'package:{{project_name}}/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:{{project_name}}/features/auth/presentation/pages/login_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHiveClient extends Mock implements HiveClient {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    final hiveClient = _MockHiveClient();
    when(() => hiveClient.clearAuthToken()).thenAnswer((_) async {});
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(repository, AuthStatusNotifier(hiveClient)),
    );
  });

  tearDown(() => getIt.reset());

  testWidgets('shows validation errors when submitting an empty form', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('submits valid credentials and shows a loading indicator', (
    tester,
  ) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return const Result.success(AuthUser(email: 'user@example.com'));
    });

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    verify(
      () =>
          repository.login(email: 'user@example.com', password: 'password123'),
    ).called(1);
  });

  testWidgets('shows a snackbar with the failure message on error', (
    tester,
  ) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(
        UnauthorizedFailure('Incorrect email or password.'),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
