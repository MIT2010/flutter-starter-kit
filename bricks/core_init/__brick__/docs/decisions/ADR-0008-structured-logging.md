# ADR-0008: Structured logging via the `logger` package

## Status

Accepted

## Context

`LoggingInterceptor` originally called `dart:developer`'s `log()` directly.
That's fine for a bare minimum, but gives no log levels, no filtering, and
plain unstructured text — awkward once an app has more than one thing
worth logging.

## Decision

Use the `logger` package (`^2.7.0`, current stable, verified live via
`flutter pub add logger`). A single shared instance is provided via DI:
`lib/core/logging/app_logger.dart`'s `LoggingModule` (an `@module`,
matching the pattern already used for `Dio` and the Hive `Box` — see
ADR-0001) registers a `@lazySingleton Logger`, configured with a compact
`PrettyPrinter` (`methodCount: 0`) suited to interleaved network log
lines.

`LoggingInterceptor` now takes this `Logger` via constructor injection and
calls `.d()` (request), `.i()` (response), `.e()` (error) instead of
`developer.log(...)`. **The existing redaction logic
(`redactSensitiveData`) is completely unchanged** — every log call still
goes through it first; only the sink changed, not what's safe to print.

Network logging is also now gated by `AppConfig.enableNetworkLogging` (see
ADR-0009) — disabled by default in `config/production.json`.

## Alternatives considered

- **`dart:developer` (status quo)**: rejected — no levels/filtering, and
  every other piece of shared infrastructure in this app (Dio, Hive) is a
  DI-provided singleton; logging should follow the same shape rather than
  being the one thing that's a bare static call.
- **`talker`** and other logging+error-tracking combo packages: heavier
  than what this starter kit needs by default; `logger` alone covers the
  one current use case (interceptor logging) without pulling in
  crash-reporting integrations a project may not want.

## Consequences

- Any future code that wants to log should inject the shared `Logger`
  (`@lazySingleton`, resolvable via `getIt<Logger>()` or constructor
  injection) rather than constructing its own `Logger()` — one shared
  printer/output configuration for the whole app.
- `LoggingInterceptor`'s constructor now takes a `Logger` — tests
  construct it with a mock (`class _MockLogger extends Mock implements
  Logger {}`; `Logger` isn't `sealed`/`final`, so this works like any other
  mocktail mock).
- `onError` passes `error: err.type` (the `DioExceptionType` enum) to
  `_logger.e(...)`, never the raw `DioException` — a security-auditor pass
  flagged that `logger`'s `PrettyPrinter` prints `error.toString()`, and
  while `DioException.toString()` doesn't currently include response body
  content, that's an upstream implementation detail this codebase doesn't
  control, not a guarantee. `err.type`'s `toString()` can never leak a
  response body — it's a fixed enum. A regression test
  (`logging_interceptor_test.dart`) asserts the logged `error:` is never a
  `DioException` instance.
