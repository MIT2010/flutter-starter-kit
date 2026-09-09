# ADR-0003: Cold-start-safe redirect guard, and why there's no full auth feature

## Status

Superseded in part by [ADR-0007](ADR-0007-auth-feature.md) — a real
`features/auth` module now exists and `LoginPlaceholderScreen`/
`simulateLogin()` have been removed, exactly as this ADR's own
"Consequences" section anticipated. The guard mechanism and
`AuthStatusNotifier`'s minimal, status-only role described below are
unchanged and still accurate — only the placeholder screen is gone.

## Context

A well-known Flutter production bug: a router's redirect guard treats
"auth status not yet resolved" the same as "resolved to logged out," so an
already-authenticated user gets bounced to `/login` on every cold start
while the stored session is still being read from local storage.

Demonstrating the fix requires *some* notion of auth status that starts
unresolved and resolves asynchronously — but the starter kit's mandate is
exactly one reference feature (`example_feature`), not a full login flow.

## Decision

`AuthStatusNotifier` (`lib/app/auth_status_notifier.dart`) is deliberately
**not** a `features/auth` module with the standard `data/domain/presentation`
layering. It's minimal app-level plumbing: a `ChangeNotifier` with three
states (`unknown`, `authenticated`, `unauthenticated`), backed by
`HiveClient`.

`main.dart` calls `configureDependencies()`, then calls
`AuthStatusNotifier.resolve()` **without awaiting it** before `runApp()` —
the app renders immediately while the check runs in the background. This is
what makes the `unknown` state actually observable; awaiting it first would
make the guard's `unknown` branch dead code that's never exercised.

`lib/app/router.dart`'s `redirect` callback:
- returns `null` (no redirect) while `status == unknown`
- redirects to `/login` only once resolved to `unauthenticated`
- redirects away from `/login` only once resolved to `authenticated`

`refreshListenable: getIt<AuthStatusNotifier>()` re-triggers the redirect
evaluation once `resolve()` completes and calls `notifyListeners()`.

`LoginPlaceholderScreen` is a bare widget (no Cubit, no repository) with a
"Simulate login" button that writes a placeholder token via
`AuthStatusNotifier.simulateLogin()` — enough to manually exercise both
branches of the guard, explicitly documented as not a real auth flow.

## Consequences

- A project that adds real authentication should scaffold a proper
  `features/auth` module (via the `feature` brick) and have it drive
  `AuthStatusNotifier` (or replace it with a richer auth state entirely) —
  `LoginPlaceholderScreen` and `simulateLogin()` are meant to be deleted at
  that point, not extended.
- Every future feature route is a single additional `GoRoute` entry in the
  existing `routes` list — never a second `GoRouter` instance.
