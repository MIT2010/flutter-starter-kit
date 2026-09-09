import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/storage/hive_client.dart';
import 'package:{{project_name}}/features/auth/data/repositories/auth_repository_impl.dart';

class _MockHiveClient extends Mock implements HiveClient {}

void main() {
  late _MockHiveClient hiveClient;
  late AuthRepositoryImpl repository;

  setUp(() {
    hiveClient = _MockHiveClient();
    repository = AuthRepositoryImpl(hiveClient);
    when(() => hiveClient.setAuthToken(any())).thenAnswer((_) async {});
    when(() => hiveClient.clearAuthToken()).thenAnswer((_) async {});
  });

  group('login', () {
    test('fails on an invalid email address', () async {
      final result = await repository.login(
        email: 'not-an-email',
        password: 'password123',
      );

      expect(result.isFailure, isTrue);
      verifyNever(() => hiveClient.setAuthToken(any()));
    });

    test('fails on a password shorter than 6 characters', () async {
      final result = await repository.login(
        email: 'user@example.com',
        password: '123',
      );

      expect(result.isFailure, isTrue);
      verifyNever(() => hiveClient.setAuthToken(any()));
    });

    test('succeeds and stores a token for valid credentials', () async {
      final result = await repository.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onFailure: (_) => fail('expected success'),
        onSuccess: (user) => expect(user.email, 'user@example.com'),
      );
      verify(() => hiveClient.setAuthToken(any())).called(1);
    });
  });

  group('logout', () {
    test('clears the stored token', () async {
      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => hiveClient.clearAuthToken()).called(1);
    });
  });
}
