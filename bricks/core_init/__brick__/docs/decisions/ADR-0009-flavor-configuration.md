# ADR-0009: Environment/flavor configuration via `--dart-define-from-file` JSON

## Status

Accepted

## Context

The starter kit needed a way to vary environment-specific values (API base
URL, whether network logging is on) across development/staging/production
without hand-editing source per environment, and without the extra native
build-configuration surface of real platform flavors (Android product
flavors + iOS schemes) — that's meaningfully more setup than this kit's
Layer 0-3, single-package scope wants as a default.

## Decision

Three JSON files at the repo root, one per environment:
`config/development.json`, `config/staging.json`, `config/production.json`
— each a flat map of `dart-define` keys (`FLAVOR`, `API_BASE_URL`,
`ENABLE_NETWORK_LOGGING`).

`lib/core/config/app_config.dart` reads them at compile time via
`String.fromEnvironment` / `bool.fromEnvironment`, each with a **default
value matching `config/development.json`** — so plain `flutter run` /
`flutter test`, with no flags at all, still work exactly as before this
change. Run with a specific environment via:

```bash
flutter run --dart-define-from-file=config/staging.json
flutter build apk --dart-define-from-file=config/production.json
```

`AppConfig.apiBaseUrl` feeds `NetworkModule.dio()` (replacing the old
hardcoded `apiBaseUrl` constant in `dio_client.dart`), and
`AppConfig.enableNetworkLogging` gates `LoggingInterceptor` (see
ADR-0008) — disabled by default in `production.json`, so nothing is
logged in a release build unless a project explicitly re-enables it.
`AppConfig.flavor` is shown in the app title outside of production
(`main.dart`), so it's visually obvious which environment is running.

All three files currently point at the same placeholder API
(`jsonplaceholder.typicode.com`) since this kit doesn't ship real
staging/production backends — replace each file's `API_BASE_URL` with the
real per-environment backend URL when you have one.

## Alternatives considered

- **Real platform flavors** (Android `productFlavors` + iOS schemes):
  rejected as the *default* — meaningfully more native-project surface
  area for a starter kit that otherwise avoids touching
  `android/`/`ios/` config. Nothing here prevents adding real flavors
  later on top of this if a project needs flavor-specific app icons,
  bundle IDs, etc. — this ADR only covers *Dart-level* config.
- **`.env` files + `flutter_dotenv`**: rejected — reads config at runtime
  from a bundled asset file, which means secrets/config ship inside the
  compiled app bundle and can be extracted from it. `--dart-define-from-file`
  bakes values in at compile time via `String.fromEnvironment`, which is
  the approach Flutter's own docs recommend for this reason.

## Consequences

- Adding a new config key means adding it to routes: (1) all three JSON
  files (or at least documenting the default for the ones that don't need
  a per-environment override), (2) a new `String`/`bool`/`int.fromEnvironment`
  field on `AppConfig` with a default matching `development.json`.
- CI's main `flutter test` run uses no flags (development defaults), plus a
  second, scoped step running just the config-sensitive tests with
  `--dart-define-from-file=config/production.json` (`.github/workflows/ci.yml`)
  — added after a security-auditor pass pointed out that without it, the
  `enableNetworkLogging == false` branch in `logging_interceptor_test.dart`
  was correct in shape but never actually executed by CI, only by manual
  local runs. Verified the override actually matters: running
  `flutter test --dart-define-from-file=config/production.json` against
  `test/core/config/app_config_test.dart` correctly *fails* the
  "defaults match development" assertions (flavor becomes `production`),
  proving values really do flow through — not just documented, observed.
- These JSON files are meant to be committed — they currently hold no
  secrets, only environment labels and a public placeholder API URL. If a
  project later adds a real API key or other secret to one of these
  files, it needs a different handling path (a gitignored
  `config/production.local.json` layered on top, a secrets manager, CI-injected
  `--dart-define` values, etc.) — don't assume everything that fits this
  file shape is safe to commit just because these three starting files are.
