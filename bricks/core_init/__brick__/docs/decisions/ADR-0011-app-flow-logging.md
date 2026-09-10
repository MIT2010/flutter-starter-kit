# ADR-0011: App-flow logging (BlocObserver + NavigatorObserver + repository exception logging)

## Status

Accepted

## Context

Before this decision, the only thing this starter kit ever logged was the
network layer (`LoggingInterceptor`, see ADR-0008) — every cubit's state
transitions, every screen navigation, and any unexpected (non-`DioException`)
exception caught inside a repository's generic `catch (_)` branch were
completely invisible. That last one is a real bug class, not a theoretical
gap: a repository method typically looks like

```dart
} on DioException catch (e) {
  return Result.failure(mapDioError(e));
} catch (_) {
  return const Result.failure(UnknownFailure());
}
```

The `on DioException` branch is fine — network failures are already visible
via `LoggingInterceptor` when `AppConfig.enableNetworkLogging` is on. The
generic `catch (_)` branch is not: it catches things like a response body
that parsed as JSON but didn't have the shape a model's `fromJson` expected
(a `data['key'] as SomeType` cast throwing) and discards the exception with
zero trace, completely indistinguishable from a routine backend rejection.
This was found live in a downstream project built on this starter kit,
while debugging a different silent-`catch (_)` bug in a location service —
the same shape of bug turned out to be repeated in every repository that
had this exact two-branch pattern.

## Decision

Three additions, all off in production behind a new flag except uncaught
cubit errors (see below):

1. **`lib/core/logging/app_bloc_observer.dart`** — an `AppBlocObserver
   extends BlocObserver`, registered once in `main.dart`
   (`Bloc.observer = getIt<AppBlocObserver>()`), so every feature's cubit
   gets creation/state-transition/close logging for free — no per-cubit code
   needed. Logs only `runtimeType` names (e.g. `AuthCubit: AuthInitial ->
   AuthLoading`), **never a state's own field values** — a `freezed` state's
   generated `toString()` can embed sensitive data (an auth token, a base64
   image), and logging it would violate the same redaction principle
   `LoggingInterceptor`/`redactSensitiveData` already enforce for network
   bodies (ADR-0008's ground rule 5 extended to this new logging surface).
2. **`lib/core/logging/app_navigator_observer.dart`** — an
   `AppNavigatorObserver extends NavigatorObserver`, attached via
   `GoRouter(observers: [...])` in `router.dart`. Logs push/pop/replace/
   remove using `route.settings.name`, which is why **every `GoRoute` now
   has a `name:`** — go_router propagates it onto the underlying `Route`,
   and without it every navigation would log as `unnamed -> unnamed`.
3. **Repository exception logging** — every repository's generic
   `catch (_)` becomes `catch (e, stackTrace)`, logging the error+stacktrace
   via the shared `Logger` before still returning the same
   `Result.failure(UnknownFailure())` the caller already expects. Nothing
   about the `Result<F,S>` contract changes — this is purely additive
   visibility. `example_feature_repository_impl.dart` demonstrates the
   pattern (the starter kit's one always-real network call), calling the
   shared `unexpectedError(logger, context, error, stackTrace)` helper in
   `lib/core/logging/unexpected_error.dart`. (Originally described here as
   a small *private* per-class helper; every downstream project promoted
   it to `core/`, so the kit now ships it there — see ADR-0014.)

`AppConfig.enableAppFlowLogging` (new, mirrors `enableNetworkLogging`
exactly — same default-true-except-production shape, same
`--dart-define-from-file` mechanism from ADR-0009) gates #1 and #2.
**`AppBlocObserver.onError` is deliberately NOT gated behind this flag** —
an uncaught exception escaping a cubit is a real bug, not routine flow
noise, and this starter kit has no separate crash-reporting channel;
suppressing it in production (as the flag does for everything else) would
make it invisible everywhere, with no alternative signal at all.

## Alternatives considered

- **Leave repository logging as a documented convention, not enforced by
  any shipped code**: rejected — this starter kit's own ground rules
  elsewhere (interceptor attachment, redaction) treat "must actually happen,
  not just be documented" as the standard; a convention nobody's forced to
  follow is exactly how the original bug shipped.
- **A crash-reporting SaaS (Sentry/Crashlytics) instead of/alongside
  `Logger`**: rejected as a default — meaningfully heavier (an account,
  an API key, a network dependency of its own) than what a starter kit
  should assume every project wants; nothing here prevents adding one
  later, and `AppBlocObserver.onError`/the repository logging both remain
  useful as local console output regardless.
- **Logging full state objects (not just type names) for richer debug
  output**: rejected — the redaction risk (a freezed state's `toString()`
  can trivially embed a token or other sensitive field) outweighs the
  convenience; a developer who needs a specific field's value for local
  debugging can always add a temporary log call for that one field.

## Consequences

- Every new repository written against this starter kit should follow the
  same two-branch-plus-logged-generic-catch shape `example_feature`
  demonstrates — `mason make feature`'s stub repository has no try/catch at
  all yet (it's a `TODO`-marked placeholder with no real data source), so
  there's nothing to retrofit there today, but the pattern should be applied
  once a generated feature's stub is filled in with a real `Dio`/storage
  call.
- Every `GoRoute` needs a `name:` going forward — `mason make feature`
  should be checked to confirm its generated route entry includes one (it
  does as of this change).
- Any repository constructor gains a required `Logger` parameter the first
  time it needs this — existing direct-construction tests must be updated
  to pass a `class _MockLogger extends Mock implements Logger {}` (same
  pattern `logging_interceptor_test.dart`/`dio_client_test.dart` already
  use; `Logger` isn't `sealed`/`final`, so this works like any other
  mocktail mock).
