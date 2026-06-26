import 'package:core/core.dart';
import 'package:shared_auth/shared_auth.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<UserEntity> call() {
    return _repository.getCurrentUser();
  }
}
