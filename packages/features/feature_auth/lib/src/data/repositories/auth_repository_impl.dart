import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:shared_auth/shared_auth.dart';
import '../../domain/entities/otp_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementasi AuthRepository.
/// Menangkap AppException dari datasource dan mengubahnya
/// menjadi Failure yang dimengerti domain layer.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  FutureEither<AuthTokenEntity> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.loginWithEmailPassword(
        email: email,
        password: password,
      );
      await _local.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresAt: model.expiresAt,
      );
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Either.left(
        ValidationFailure(message: e.message, messages: e.messages),
      );
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('loginWithEmailPassword error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<OtpEntity> requestOtp({required String destination}) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.requestOtp(destination: destination);
      return Either.right(model.toEntity());
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('requestOtp error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<AuthTokenEntity> verifyOtp({
    required String destination,
    required String code,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.verifyOtp(
        destination: destination,
        code: code,
      );
      await _local.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresAt: model.expiresAt,
      );
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('verifyOtp error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<AuthTokenEntity> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final model = await _remote.refreshToken(refreshToken: refreshToken);
      await _local.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresAt: model.expiresAt,
      );
      return Either.right(model.toEntity());
    } on UnauthorizedException {
      await _local.clearAll();
      return Either.left(const UnauthorizedFailure());
    } catch (e) {
      AppLogger.error('refreshToken error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<UserEntity> getCurrentUser() async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.getCurrentUser();
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('getCurrentUser error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<Unit> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Tetap hapus local session meski API logout gagal
    } finally {
      await _local.clearAll();
    }
    return Either.right(unit);
  }
}
