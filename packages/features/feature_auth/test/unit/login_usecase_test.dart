import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_auth/shared_auth.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginWithEmailPasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  final tToken = AuthTokenEntity(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithEmailPasswordUseCase(mockRepository);

    // Provide dummy values untuk Either types
    provideDummy<Either<Failure, AuthTokenEntity>>(Either.right(tToken));
  });

  group('LoginWithEmailPasswordUseCase', () {
    test('harus mengembalikan AuthTokenEntity saat login berhasil', () async {
      when(
        mockRepository.loginWithEmailPassword(
          email: 'test@email.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => Either.right(tToken));

      final result = await useCase(
        const LoginWithEmailPasswordParams(
          email: 'test@email.com',
          password: 'password123',
        ),
      );

      expect(result, Either.right(tToken));
      verify(
        mockRepository.loginWithEmailPassword(
          email: 'test@email.com',
          password: 'password123',
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('harus mengembalikan ValidationFailure saat email kosong', () async {
      final result = await useCase(
        const LoginWithEmailPasswordParams(email: '', password: 'password123'),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
      verifyNever(
        mockRepository.loginWithEmailPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    test(
      'harus mengembalikan ValidationFailure saat password kosong',
      () async {
        final result = await useCase(
          const LoginWithEmailPasswordParams(
            email: 'test@email.com',
            password: '',
          ),
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Seharusnya gagal'),
        );
      },
    );

    test(
      'harus mengembalikan UnauthorizedFailure saat credential salah',
      () async {
        when(
          mockRepository.loginWithEmailPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Either.left(const UnauthorizedFailure()));

        final result = await useCase(
          const LoginWithEmailPasswordParams(
            email: 'wrong@email.com',
            password: 'wrongpassword',
          ),
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (_) => fail('Seharusnya gagal'),
        );
      },
    );

    test('harus mengembalikan NetworkFailure saat tidak ada koneksi', () async {
      when(
        mockRepository.loginWithEmailPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Either.left(const NetworkFailure()));

      final result = await useCase(
        const LoginWithEmailPasswordParams(
          email: 'test@email.com',
          password: 'password123',
        ),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
    });
  });
}
