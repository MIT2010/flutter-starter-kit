import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_auth/shared_auth.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailPasswordUseCase {
  const LoginWithEmailPasswordUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<AuthTokenEntity> call(LoginWithEmailPasswordParams params) {
    if (params.email.isEmpty || params.password.isEmpty) {
      return Future.value(
        Either.left(
          const ValidationFailure(message: 'Email dan password wajib diisi'),
        ),
      );
    }

    return _repository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginWithEmailPasswordParams extends Equatable {
  const LoginWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
