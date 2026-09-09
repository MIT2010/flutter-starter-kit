# ADR-0012: SessionExpiryInterceptor is the default third interceptor

## Status

Accepted

## Context

The shared `Dio` client attaches three app-defined interceptors:
`AuthInterceptor` (attach bearer token), `LoggingInterceptor` (redacted
logging), and one that handles a 401.

The kit originally shipped `RefreshTokenInterceptor` in that third slot:
on a 401 it POSTs to `/auth/refresh` with a stored `refresh_token` on a
separate bare `Dio`, saves the new token, and retries the original
request once. This assumes the backend issues refresh tokens.

Across the real apps migrated onto this kit, that assumption never held.
Every one of them had no `/auth/refresh` endpoint and no refresh-token
concept — one opaque access token, and a 401 (or, in one case, a `200`
carrying `{result: 'error', msg: '...'}`) simply means the session is
over. Each migration replaced or gutted `RefreshTokenInterceptor` with
the same shape: on a 401 outside the login endpoint, clear the token,
tell `AuthStatusNotifier`, let the router redirect to `/login`. No
refresh call, no retry, no second `Dio`.

## Decision

- `lib/core/network/interceptors/session_expiry_interceptor.dart` is the
  default third interceptor. On a 401/403 outside
  `sessionExpiryExcludedPaths` it calls
  `AuthStatusNotifier.markUnauthenticated()` (fire-and-forget) and lets
  the original error propagate. The router's `refreshListenable` does the
  rest.
- `sessionExpiryExcludedPaths` (currently `{'/auth/login'}`) is ground
  rule 5's login-exclusion requirement applied to the
  redirect-on-401 path rather than a retry-on-401 path — a failed login
  returns 401 as a normal outcome and must not be read as "session
  expired." Extend it with register / forgot-password / any other
  unauthenticated endpoint.
- The pure predicate `isSessionExpired(DioException)` is separate from the
  interceptor so it is unit-tested without Dio or GetIt, matching
  `shouldAttemptRefresh`'s split.
- `refresh_token_interceptor.dart` and its test stay in the tree,
  unchanged, unattached. A backend that does issue refresh tokens swaps
  it back into `dio_client.dart` — update the interceptor list,
  `expectedInterceptorCount`, and `dio_client_test.dart`'s `whereType`
  check together. `expectedInterceptorCount` stays `3` either way.
- This interceptor imports `app/auth_status_notifier.dart`. That is one
  `core -> app` reference, accepted deliberately: `AuthStatusNotifier` is
  the app-wide session signal the router already depends on, it holds no
  network logic, and it does not import back into `core/network/`, so
  there is no cycle. The alternative (a bespoke callback abstraction)
  adds a layer for no real gain — every migration wired the interceptor
  straight to the notifier.

## Alternatives considered

- **Keep `RefreshTokenInterceptor` as the default**: rejected — it was
  dead weight in every migration, and a `refresh_token` key that is
  always null makes a 401 surface as a generic failure with the app
  still believing it is authenticated.
- **Ship both, attach neither, force a choice at generation time**:
  rejected — a new project should have a working 401 path out of the
  box, and "log out on 401" is the safe default for a backend whose auth
  scheme is not yet known.
- **A callback/interface instead of importing `AuthStatusNotifier`**:
  rejected as unnecessary indirection — see the last Decision point.

## Consequences

- A generated app's default 401 behaviour is "log out and go to
  `/login`", not "try to refresh". One file swap in `dio_client.dart`
  restores refresh-and-retry for a backend that supports it.
- Ground rule 5 in `CLAUDE.md` is worded around "token-refresh-on-401";
  it now also covers "forced-logout-and-redirect-on-401" — either way the
  login/auth endpoint(s) must be excluded.
- `AuthStatusNotifier` gains one more caller. `markUnauthenticated()` is
  idempotent, so a burst of 401s during a dropped session just settles on
  `unauthenticated` once.
