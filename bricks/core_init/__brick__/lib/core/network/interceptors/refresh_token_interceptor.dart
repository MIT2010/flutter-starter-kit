import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../storage/hive_client.dart';

/// Endpoints that must NEVER trigger a refresh-and-retry.
///
/// Refreshing on a 401 from the login endpoint itself would retry a failed
/// login forever — this is a known production bug pattern. Extend this list
/// with any other unauthenticated endpoint (register, forgot-password, the
/// refresh endpoint itself) that can legitimately return 401/403.
const refreshExcludedPaths = <String>{'/auth/login', '/auth/refresh'};

/// Pure decision function, kept separate from [RefreshTokenInterceptor] so
/// the login/auth exclusion can be unit-tested without touching Dio or
/// GetIt. A failed login (or a failed refresh call itself) must never
/// trigger another refresh-and-retry — that's the infinite-loop bug this
/// guards against.
bool shouldAttemptRefresh(DioException err) {
  final isUnauthorized = err.response?.statusCode == 401;
  final isExcludedPath = refreshExcludedPaths.contains(err.requestOptions.path);
  final alreadyRetried =
      err.requestOptions.extra['retriedAfterRefresh'] == true;
  return isUnauthorized && !isExcludedPath && !alreadyRetried;
}

/// Refreshes the access token on a 401 and retries the original request
/// exactly once.
///
/// NOT attached by default. The default third interceptor is
/// [SessionExpiryInterceptor] (401 -> log out), because most backends this
/// kit targets issue a single opaque token with no refresh endpoint. Swap
/// this in for [SessionExpiryInterceptor] in `dio_client.dart` if your
/// backend does issue refresh tokens — see docs/decisions/ADR-0012 — and
/// update the interceptor list, `expectedInterceptorCount`, and
/// `dio_client_test.dart` together.
///
/// Defining this class is not enough on its own — it must actually be added
/// to the shared [Dio] instance's interceptor list, see `dio_client.dart`.
@injectable
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(this._hiveClient);

  final HiveClient _hiveClient;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _refreshToken();
      if (newToken == null) {
        handler.next(err);
        return;
      }

      await _hiveClient.setAuthToken(newToken);

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['retriedAfterRefresh'] = true;

      final sharedDio = GetIt.instance<Dio>();
      final response = await sharedDio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  /// Calls the refresh endpoint on a bare [Dio] instance — deliberately not
  /// the shared one, so this call never re-enters this same interceptor.
  Future<String?> _refreshToken() async {
    final refreshDio = Dio(
      BaseOptions(baseUrl: (GetIt.instance<Dio>()).options.baseUrl),
    );
    final response = await refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': _hiveClient.read<String>('refresh_token')},
    );
    return response.data?['accessToken'] as String?;
  }
}
