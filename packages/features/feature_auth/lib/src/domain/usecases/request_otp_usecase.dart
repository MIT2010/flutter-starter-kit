import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import '../entities/otp_entity.dart';
import '../repositories/auth_repository.dart';

class RequestOtpUseCase {
  const RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<OtpEntity> call(RequestOtpParams params) {
    if (params.destination.isEmpty) {
      return Future.value(
        Either.left(
          const ValidationFailure(message: 'Nomor HP atau email wajib diisi'),
        ),
      );
    }

    return _repository.requestOtp(destination: params.destination);
  }
}

class RequestOtpParams extends Equatable {
  const RequestOtpParams({required this.destination});

  final String destination;

  @override
  List<Object?> get props => [destination];
}
