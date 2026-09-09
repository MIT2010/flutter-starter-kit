import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/auth_status_notifier.dart';

/// Endpoints that must NEVER be treated as "session expired" on a 401/403.
///
/// A failed login legitimately returns 401 — treating that as an expired
/// session would knock the user off the login screen they're already on
/// (a redirect loop in spirit, even though nothing here retries). Extend
/// this with register / forgot-password / any other unauthenticated
/// endpoint that can return 401/403 as a normal outcome. This is ground
/// rule 5's login-exclusion requirement, applied to the redirect-on-401
/// path instead of a retry-on-401 path.
const sessionExpiryExcludedPaths = <String>{'/auth/login'};

/// Pure decision function, kept separate from [SessionExpiryInterceptor] so
/// the exclusion can be unit-tested without touching Dio or GetIt.
bool isSessionExpired(DioException err) {
  final code = err.response?.statusCode;
  final isAuthFailure = code == 401 || code == 403;
  final isExcluded = sessionExpiryExcludedPaths.contains(
    err.requestOptions.path,
  );
  return isAuthFailure && !isExcluded;
}

/// On any 401/403 outside [sessionExpiryExcludedPaths], marks the session
/// unauthenticated and lets the original error propagate. No refresh call,
/// no retry, no second [Dio] instance — a 401 here means the session is
/// genuinely over. The router listens to [AuthStatusNotifier] and
/// redirects to `/login`.
///
/// This is the DEFAULT third interceptor. Most backends this kit has been
/// used against issue a single opaque token with no refresh endpoint, so
/// "401 -> log out" is the common case and refresh-and-retry is the
/// exception. If your backend DOES issue refresh tokens, swap this for
/// [RefreshTokenInterceptor] (still in this folder) in `dio_client.dart`
/// and update the interceptor list, [expectedInterceptorCount], and
/// `dio_client_test.dart`'s type check together. See
/// docs/decisions/ADR-0012.
///
/// Defining this class is not enough on its own — it must actually be
/// added to the shared [Dio] instance's interceptor list, see
/// `dio_client.dart`.
@injectable
class SessionExpiryInterceptor extends Interceptor {
  SessionExpiryInterceptor(this._authStatusNotifier);

  final AuthStatusNotifier _authStatusNotifier;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isSessionExpired(err)) {
      // Fire-and-forget: clears the stored token and notifies the router's
      // refreshListenable, which redirects to /login. Nothing here needs
      // to wait for that to finish before letting the original error
      // propagate.
      unawaited(_authStatusNotifier.markUnauthenticated());
    }
    handler.next(err);
  }
}
