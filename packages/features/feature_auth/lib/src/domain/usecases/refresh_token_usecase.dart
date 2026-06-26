import 'package:core/core.dart';
import 'package:shared_auth/shared_auth.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<AuthTokenEntity> call(String refreshToken) {
    return _repository.refreshToken(refreshToken: refreshToken);
  }
}
