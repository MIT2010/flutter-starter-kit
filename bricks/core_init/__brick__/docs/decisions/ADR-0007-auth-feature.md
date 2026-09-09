# ADR-0007: A real `auth` feature, with locally-simulated login by default

## Status

Accepted

## Context

The starter kit shipped with `LoginPlaceholderScreen` — deliberately not a
real feature (see ADR-0003) — just enough to demonstrate the router's
cold-start-safe redirect guard. A real, properly-layered authentication
feature was requested as a default, working part of the kit.

That raises a question ADR-0003 punted on: what backend does a *default*
login flow call? Checked live before deciding:

- **reqres.in** (the common fake-auth test API) now requires a paid API
  key even for its login demo endpoint (confirmed: `POST /api/login`
  returns `401 missing_api_key`).
- **jsonplaceholder.typicode.com** (this kit's example-feature API) has no
  auth endpoints at all — posting to `/auth/login` there would 404.

Shipping a "real" network call that's broken out of the box — for the one
feature most associated with security — is worse than an honest, working
simulation.

## Decision

`features/auth` is a normal, fully-layered feature:

- `domain/repositories/auth_repository.dart` — `login({email, password})`
  returns `Result<Failure, AuthUser>`; `logout()` returns
  `Result<Failure, void>`.
- `data/repositories/auth_repository_impl.dart` — validates email format and
  a minimum password length, then stores a token via `HiveClient`. **No
  network call.** The class doc comment spells out exactly how to replace
  it with a real `Dio` call to `POST {apiBaseUrl}/auth/login`, and notes
  that `RefreshTokenInterceptor` already excludes `/auth/login` and
  `/auth/refresh` from its retry logic — those paths were reserved for
  this from the start (see ground rule 5 / ADR on the refresh interceptor),
  so wiring a real backend using them won't reintroduce the refresh-loop
  bug this kit specifically guards against.
- `presentation/cubit/auth_cubit.dart` (`AuthCubit`/`AuthState`) — on a
  successful login, calls `AuthStatusNotifier.markAuthenticated()`; on
  logout, calls the repository then `AuthStatusNotifier.markUnauthenticated()`.
  `AuthStatusNotifier` itself still only holds resolution *status* for the
  router guard — it never talks to a repository directly (see ADR-0003).
- `presentation/pages/login_page.dart` (`LoginPage`) — a real form
  (email/password validation, loading state, error snackbar), replacing
  `LoginPlaceholderScreen` at the `/login` route. (Originally
  `presentation/view/login_screen.dart`/`LoginScreen` — see ADR-0010 for
  the `pages`/`*Page` rename.)

`LoginPlaceholderScreen` and `AuthStatusNotifier.simulateLogin()` are
removed, per ADR-0003's own stated intent ("meant to be deleted... not
extended"). A small logout `IconButton` was added to `example_feature`'s
`AppBar` so the full login → home → logout round trip is reachable in the
running app, not just in tests.

## Alternatives considered

- **A real call to reqres.in or another public fake-auth API**: rejected —
  requires a paid API key (reqres.in) or doesn't exist (jsonplaceholder),
  either of which makes the *default* experience unreliable or broken.
- **No default auth feature at all** (leave it to the user): rejected per
  the explicit ask for this to be a working, built-in default.

## Consequences

- Any password of 6+ characters and a syntactically valid email succeeds —
  this is intentionally permissive demo logic, not real security. It must
  be replaced before shipping to production, exactly like
  `example_feature`'s placeholder API.
- Wiring a real backend means replacing `AuthRepositoryImpl`'s body only —
  the interface, cubit, state, and screen don't need to change.
- After a demo login, `AuthInterceptor` attaches the fabricated
  `demo-token-*` string as a Bearer header to every request the shared
  `Dio` makes — including `example_feature`'s real calls to
  `jsonplaceholder.typicode.com`. It's not a secret and isn't checked by
  anything, but it's not scoped to a particular backend either. When you
  wire a real `AuthRepositoryImpl`, make sure the real token replaces it
  entirely (nothing else needs to change) rather than the two coexisting.
