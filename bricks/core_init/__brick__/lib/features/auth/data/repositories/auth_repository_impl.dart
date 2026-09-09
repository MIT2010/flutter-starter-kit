import 'package:injectable/injectable.dart';

import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/storage/hive_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_user_model.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Default login logic — validates input and stores a token locally,
/// with NO real network call. See ADR-0007 for why: this starter kit
/// deliberately doesn't depend on a third-party demo auth API (the common
/// options either require a paid API key or don't expose auth endpoints
/// at all), and a broken-by-default "real" call would be worse than an
/// honest, working simulation.
///
/// To wire a real backend: replace the body below with a `Dio` call via
/// the shared client (see `example_feature`'s repository for the
/// `Dio` + `mapDioError` pattern) to `POST {apiBaseUrl}/auth/login`.
/// `RefreshTokenInterceptor` already excludes `/auth/login` and
/// `/auth/refresh` from its retry logic, so a real backend using those
/// exact paths won't trigger a refresh loop on a failed login.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._hiveClient);

  final HiveClient _hiveClient;

  @override
  Future<Result<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!_emailPattern.hasMatch(email)) {
      return const Result.failure(
        UnauthorizedFailure('Enter a valid email address.'),
      );
    }
    if (password.length < 6) {
      return const Result.failure(
        UnauthorizedFailure('Incorrect email or password.'),
      );
    }

    await _hiveClient.setAuthToken('demo-token-${email.hashCode}');
    return Result.success(AuthUser(email: email));
  }

  @override
  Future<Result<Failure, void>> logout() async {
    await _hiveClient.clearAuthToken();
    return const Result.success(null);
  }
}
