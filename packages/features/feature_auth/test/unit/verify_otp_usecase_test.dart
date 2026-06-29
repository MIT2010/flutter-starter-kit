import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_auth/shared_auth.dart';

import 'verify_otp_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late VerifyOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  final tToken = AuthTokenEntity(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);

    provideDummy<Either<Failure, AuthTokenEntity>>(Either.right(tToken));
  });

  group('VerifyOtpUseCase', () {
    test('harus mengembalikan AuthTokenEntity saat OTP valid', () async {
      when(
        mockRepository.verifyOtp(destination: '08123456789', code: '123456'),
      ).thenAnswer((_) async => Either.right(tToken));

      final result = await useCase(
        const VerifyOtpParams(destination: '08123456789', code: '123456'),
      );

      expect(result, Either.right(tToken));
    });

    test('harus mengembalikan ValidationFailure saat kode kosong', () async {
      final result = await useCase(
        const VerifyOtpParams(destination: '08123456789', code: ''),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
      verifyNever(
        mockRepository.verifyOtp(
          destination: anyNamed('destination'),
          code: anyNamed('code'),
        ),
      );
    });

    test(
      'harus mengembalikan ValidationFailure saat kode bukan 6 digit',
      () async {
        final result = await useCase(
          const VerifyOtpParams(destination: '08123456789', code: '123'),
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('6 digit'));
        }, (_) => fail('Seharusnya gagal'));
      },
    );

    test('harus mengembalikan ServerFailure saat OTP salah', () async {
      when(
        mockRepository.verifyOtp(
          destination: anyNamed('destination'),
          code: anyNamed('code'),
        ),
      ).thenAnswer(
        (_) async =>
            Either.left(const ServerFailure(message: 'Kode OTP tidak valid')),
      );

      final result = await useCase(
        const VerifyOtpParams(destination: '08123456789', code: '000000'),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
    });
  });
}
