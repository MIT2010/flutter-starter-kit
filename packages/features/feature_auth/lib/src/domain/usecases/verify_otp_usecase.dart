import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_auth/shared_auth.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<AuthTokenEntity> call(VerifyOtpParams params) {
    if (params.code.isEmpty) {
      return Future.value(
        Either.left(
          const ValidationFailure(message: 'Kode OTP wajib diisi'),
        ),
      );
    }

    if (params.code.length != 6) {
      return Future.value(
        Either.left(
          const ValidationFailure(message: 'Kode OTP harus 6 digit'),
        ),
      );
    }

    return _repository.verifyOtp(
      destination: params.destination,
      code: params.code,
    );
  }
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({
    required this.destination,
    required this.code,
  });

  final String destination;
  final String code;

  @override
  List<Object?> get props => [destination, code];
}
