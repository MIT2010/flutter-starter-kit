import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/app/auth_status_notifier.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/result.dart';
import 'package:{{project_name}}/core/storage/hive_client.dart';
import 'package:{{project_name}}/features/auth/data/models/auth_user_model.dart';
import 'package:{{project_name}}/features/auth/domain/repositories/auth_repository.dart';
import 'package:{{project_name}}/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:{{project_name}}/features/auth/presentation/cubit/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHiveClient extends Mock implements HiveClient {}

void main() {
  late _MockAuthRepository repository;
  late AuthStatusNotifier authStatusNotifier;

  setUp(() {
    repository = _MockAuthRepository();
    final hiveClient = _MockHiveClient();
    when(() => hiveClient.clearAuthToken()).thenAnswer((_) async {});
    authStatusNotifier = AuthStatusNotifier(hiveClient);
  });

  const user = AuthUser(email: 'user@example.com');

  blocTest<AuthCubit, AuthState>(
    'emits [loading, success] and marks the app authenticated on success',
    build: () {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Result.success(user));
      return AuthCubit(repository, authStatusNotifier);
    },
    act: (cubit) => cubit.login(email: user.email, password: 'password123'),
    expect: () => [const AuthState.loading(), const AuthState.success(user)],
    verify: (_) => expect(authStatusNotifier.status, AuthStatus.authenticated),
  );

  blocTest<AuthCubit, AuthState>(
    'emits [loading, error] and does not change auth status on failure',
    build: () {
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
      return AuthCubit(repository, authStatusNotifier);
    },
    act: (cubit) => cubit.login(email: user.email, password: 'wrong'),
    expect: () => [
      const AuthState.loading(),
      const AuthState.error(
        UnauthorizedFailure('Incorrect email or password.'),
      ),
    ],
    verify: (_) =>
        expect(authStatusNotifier.status, isNot(AuthStatus.authenticated)),
  );

  blocTest<AuthCubit, AuthState>(
    'logout clears the repository session and marks the app unauthenticated',
    build: () {
      when(
        () => repository.logout(),
      ).thenAnswer((_) async => const Result.success(null));
      return AuthCubit(repository, authStatusNotifier);
    },
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState.initial()],
    verify: (_) {
      verify(() => repository.logout()).called(1);
      expect(authStatusNotifier.status, AuthStatus.unauthenticated);
    },
  );
}
