import 'package:core/core.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  FutureEither<Unit> call() {
    return _repository.logout();
  }
}
