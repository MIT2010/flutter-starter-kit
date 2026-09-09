# Proposal: SessionExpiryInterceptor as the default, refresh-token opt-in

Status: **APPLIED 2026-08-27**. Superseded by
`bricks/core_init/__brick__/docs/decisions/ADR-0012-session-expiry-interceptor.md`.
Verified end-to-end: `mason make core_init` + `mason make feature` →
`flutter analyze` clean → `flutter test` 45/45 then 50/50. This file is
kept for the diff/rationale history only.

Author note: raised by the 2026-08-27 cross-project audit. Evidence lives
in the vault at `14 - Engineering Journal/Case Studies/011 - Session-Expiry
Interceptor Is the Default, Not Refresh-Token.md`.

## Problem

`bricks/core_init` ships `RefreshTokenInterceptor` in the default network
layer: on a 401 it POSTs to `/auth/refresh` on a bare `Dio`, stores the
new token, retries once. This assumes the backend issues refresh tokens.

Three production apps were migrated onto this kit. None could use it:

| App | Backend reality | What replaced it |
|---|---|---|
| `etle_mobile` | No bearer auth at all; session expiry signalled by `200` + `{result:'error', msg:'Silakan Login'}`, not `401` | `SessionExpiryInterceptor` watching that body shape |
| `visitasi_sekolah_mengemudi` | No refresh-token concept | `SessionExpiryInterceptor`: 401 outside `/auth/login` → clear token → notify `AuthStatusNotifier` |
| `siap_jalan` | No `/auth/refresh` endpoint | Same interceptor, name kept, refresh logic gutted |

The common real case is "401 means the session is over — drop the token,
send the user to the entry screen." Refresh-token flow is the exception.
The kit has the default backwards, so every migration re-derives the same
replacement.

## Proposal

1. Add `lib/core/network/interceptors/session_expiry_interceptor.dart` as
   the **default** third interceptor.
2. Keep `refresh_token_interceptor.dart` in the tree, unattached, as a
   documented opt-in. Its `shouldAttemptRefresh` pure function and its
   test stay exactly as they are.
3. `expectedInterceptorCount` stays `3` (auth, logging, sessionExpiry).
4. New ADR-0012 in `__brick__/docs/decisions/` (Accepted, once verified)
   explaining the default and pointing at the opt-in swap. This ADR must
   explicitly re-affirm ground rule 5's login-endpoint-exclusion
   requirement — it still applies, just to the redirect-on-401 path
   instead of a retry-on-401 path.
5. QUICKSTART + `flutter-starter-kit-conventions` skill
   (`references/folder-structure.md`) updated to name
   `session_expiry_interceptor.dart` as the default.

### New file: `session_expiry_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/auth_status_notifier.dart';

/// Endpoints that must NEVER trigger a forced logout on 401/403.
///
/// A failed login legitimately returns 401 — treating that as "session
/// expired" would bounce the user off the login screen they're already on
/// (a redirect loop in spirit, even with no retry mechanism to loop).
/// Extend with register / forgot-password / any other unauthenticated
/// endpoint. This is ground rule 5's login-exclusion requirement, applied
/// to the redirect-on-401 path.
const sessionExpiryExcludedPaths = <String>{'/auth/login'};

/// Pure decision function, kept separate from [SessionExpiryInterceptor]
/// so the exclusion can be unit-tested without Dio or GetIt.
bool isSessionExpired(DioException err) {
  final code = err.response?.statusCode;
  final isAuthFailure = code == 401 || code == 403;
  final isExcluded =
      sessionExpiryExcludedPaths.contains(err.requestOptions.path);
  return isAuthFailure && !isExcluded;
}

/// On any 401/403 outside [sessionExpiryExcludedPaths], marks the session
/// unauthenticated and lets the original error propagate. No refresh call,
/// no retry, no second Dio instance — a 401 here means the session is
/// genuinely over. The router listens to [AuthStatusNotifier] and
/// redirects to /login.
///
/// If your backend DOES issue refresh tokens, swap this out for
/// `RefreshTokenInterceptor` (still in this folder) in `dio_client.dart`
/// and update the interceptor list + count + `dio_client_test.dart`
/// together.
///
/// Defining this class is not enough — it must actually be added to the
/// shared [Dio] instance's interceptor list, see `dio_client.dart`.
@injectable
class SessionExpiryInterceptor extends Interceptor {
  SessionExpiryInterceptor(this._authStatusNotifier);

  final AuthStatusNotifier _authStatusNotifier;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isSessionExpired(err)) {
      // fire-and-forget: clears the stored token and notifies the router
      _authStatusNotifier.markUnauthenticated();
    }
    handler.next(err);
  }
}
```

### `dio_client.dart` diff

```diff
-import 'interceptors/refresh_token_interceptor.dart';
+import 'interceptors/session_expiry_interceptor.dart';
@@
   Dio dio(
     AuthInterceptor authInterceptor,
     LoggingInterceptor loggingInterceptor,
-    RefreshTokenInterceptor refreshTokenInterceptor,
+    SessionExpiryInterceptor sessionExpiryInterceptor,
   ) {
     final ourInterceptors = [
       authInterceptor,
       loggingInterceptor,
-      refreshTokenInterceptor,
+      sessionExpiryInterceptor,
     ];
```

### `dio_client_test.dart` diff

```diff
-import 'package:{{project_name}}/core/network/interceptors/refresh_token_interceptor.dart';
+import 'package:{{project_name}}/core/network/interceptors/session_expiry_interceptor.dart';
+import 'package:{{project_name}}/app/auth_status_notifier.dart';
@@
+class _MockAuthStatusNotifier extends Mock implements AuthStatusNotifier {}
@@
     final dio = module.dio(
       AuthInterceptor(hiveClient),
       LoggingInterceptor(_MockLogger()),
-      RefreshTokenInterceptor(hiveClient),
+      SessionExpiryInterceptor(_MockAuthStatusNotifier()),
     );
@@
-    expect(dio.interceptors.whereType<RefreshTokenInterceptor>(), hasLength(1));
+    expect(dio.interceptors.whereType<SessionExpiryInterceptor>(), hasLength(1));
```

### New `session_expiry_interceptor_test.dart`

Mirror the existing `refresh_token_interceptor_test.dart` structure:
`isSessionExpired` is false for `/auth/login` (regression guard: a failed
login must not force a logout), false for non-401/403, true for a
first-time 401 or 403 on a normal endpoint.

### `refresh_token_interceptor.dart` / its test

Unchanged. Both stay in the tree. Add one line to the class doc comment:
"Not attached by default — see `session_expiry_interceptor.dart`. Swap in
`dio_client.dart` if your backend issues refresh tokens."

## Consequences

- The generated app's default behaviour on 401 becomes "log out and go to
  /login" instead of "try to refresh." For a backend with refresh tokens,
  one file swap in `dio_client.dart` restores the old behaviour.
- `AuthStatusNotifier` gains one more caller (`SessionExpiryInterceptor`),
  which is fine — it's already the app-wide session signal and
  `markUnauthenticated()` is idempotent.
- Ground rule 5 in `CLAUDE.md` mentions "a token-refresh-on-401 mechanism
  must exclude the login endpoint." Reword to "any automatic 401 handler
  (refresh-and-retry OR forced-logout-and-redirect) must exclude the
  login/auth endpoint(s)."

## Verification checklist before applying

- [ ] `mason make core_init -o ../scratch --project_name scratch`
- [ ] `cd ../scratch && flutter pub get && dart run build_runner build`
- [ ] `flutter analyze` clean
- [ ] `flutter test` green (esp. `dio_client_test`, the new
      `session_expiry_interceptor_test`, and `auth` tests)
- [ ] `mason make feature` into the scratch project still wires up and
      passes
