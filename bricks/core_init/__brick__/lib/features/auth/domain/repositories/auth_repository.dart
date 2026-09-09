import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../data/models/auth_user_model.dart';

/// What the presentation layer depends on — never the concrete
/// implementation. Lets [AuthCubit] be unit-tested against a mock.
abstract class AuthRepository {
  Future<Result<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Result<Failure, void>> logout();
}
