import 'package:core/core.dart';
import 'package:shared_auth/shared_auth.dart';
import '../entities/otp_entity.dart';

abstract class AuthRepository {
  FutureEither<AuthTokenEntity> loginWithEmailPassword({
    required String email,
    required String password,
  });

  FutureEither<OtpEntity> requestOtp({required String destination});

  FutureEither<AuthTokenEntity> verifyOtp({
    required String destination,
    required String code,
  });

  FutureEither<AuthTokenEntity> refreshToken({required String refreshToken});

  FutureEither<UserEntity> getCurrentUser();

  FutureEither<Unit> logout();
}
