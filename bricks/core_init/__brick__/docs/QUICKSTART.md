# Quickstart

Get from a freshly generated project to a running example screen. This is
the only doc you need to read to get started.

## 1. Install dependencies

```bash
flutter pub get
```

## 2. Generate code

`freezed`, `json_serializable`, and `injectable` all rely on generated code
(`*.freezed.dart`, `*.g.dart`, `lib/app/di.config.dart`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run this any time you add or change a `@freezed` class, a `fromJson`
model, or an `@injectable`/`@lazySingleton`/`@module` class.

## 3. Run the app

```bash
flutter run
```

This uses the `development` environment by default (see `config/` and
ADR-0009) — no flags needed. To run against a different environment:

```bash
flutter run --dart-define-from-file=config/staging.json
flutter run --dart-define-from-file=config/production.json
```

You'll land on the login screen first — there's no stored session yet, so
the auth guard redirects you there (this is correct, not a bug; see
ADR-0003). Log in with any syntactically valid email and a password of 6+
characters (this is a locally-simulated default login, not checked against
a real backend — see ADR-0007 for why, and how to wire up a real one).
You'll then see the example feature screen, which fetches and displays a
single item from a placeholder API (`API_BASE_URL` in `config/*.json` —
see ADR-0009 — currently `https://jsonplaceholder.typicode.com` for every
environment; replace with your own backend). Use the logout icon in its
app bar to sign out again.

## What you're looking at

- `lib/core/` — cross-feature building blocks: `Result<F, S>` /
  `Failure` (ADR-0005), the shared `Dio` client + interceptors, local
  storage (`HiveClient`, ADR-0002).
- `lib/app/` — DI wiring (ADR-0001), the single `GoRouter` instance and its
  cold-start-safe auth redirect guard (ADR-0003), the `requireExtra<T>()`
  route guard (use it on any route that reads `state.extra` — see its doc
  comment), and the theme scaffold: a placeholder `ColorScheme` (replace
  freely — no visual-identity opinion here) plus the `AppSpacing` scale,
  read as `context.spacing.md` (a valueless step scale, not a design
  system — ADR-0013).
- `lib/features/example_feature/` — the living reference feature for a
  real network-backed read. Every feature, however small, follows this
  exact `data/domain/presentation` shape — no exceptions, no flattened
  variant. Read this feature's four files top to bottom before writing
  your first real feature; it's a template, not just an example.
- `lib/features/auth/` — the default login/logout feature (ADR-0007).
  Locally-simulated by default (no backend required out of the box) —
  replace `AuthRepositoryImpl`'s body with a real `Dio` call when you have
  a backend; nothing else in the feature needs to change.
- `config/*.json` + `lib/core/config/app_config.dart` — per-environment
  configuration loaded via `--dart-define-from-file` (ADR-0009), and the
  shared `Logger` (ADR-0008) that `LoggingInterceptor` uses, gated by
  `AppConfig.enableNetworkLogging`.
- App-flow logging (ADR-0011) — not just the network layer. Run the app
  with `flutter run` and watch the console: `AppBlocObserver`
  (`lib/core/logging/app_bloc_observer.dart`) logs every cubit's
  creation/state-transitions/close, and `AppNavigatorObserver`
  (`lib/core/logging/app_navigator_observer.dart`) logs every screen
  navigation — both gated by `AppConfig.enableAppFlowLogging` (on by
  default outside production, same shape as `enableNetworkLogging`).
  Repository methods also log any unexpected (non-`DioException`)
  exception before converting it to a generic `Failure` — see
  `example_feature_repository_impl.dart` for the pattern to follow in your
  own repositories.

## Adding a new feature

Never hand-create the `data/domain/presentation` folders yourself. From
the project root (there is a `mason.yaml` here registering the `feature`
brick):

```bash
mason get
mason make feature --feature_name my_feature
```

This generates all three layers, registers DI, and adds a route skeleton in
one pass. The package name for the generated test imports is read from
this project's `pubspec.yaml`, so you don't pass it (ADR-0015). Run the
command from the project root — the hook reads `./pubspec.yaml` and
`./lib/app/router.dart` from there. See `docs/decisions/` for the
reasoning behind the "always use the generator" rule.

**Windows:** `mason get` pulls the `feature` brick from the starter kit's
git repo into a cache directory whose path is long enough that, combined
with a long user name, it can exceed the 260-character limit and fail with
`PathNotFoundException: Directory listing failed`. If that happens, move
the cache once:

```bat
setx MASON_CACHE C:\mc
```

then re-run `mason get` from a new terminal. (macOS/Linux don't hit this.)

## Tests

```bash
flutter test
```

Golden tests load real fonts before rendering (see
`test/flutter_test_config.dart`) — without that, typography regressions
would pass silently. See `test/features/example_feature/` for the pattern:
one Cubit test (success + failure `Result` paths) and one widget/golden test
per feature.

## App icon and splash screen

`flutter_launcher_icons` and `flutter_native_splash` are already
`dev_dependencies`, with a config file each at the repo root
(`flutter_launcher_icons.yaml`, `flutter_native_splash.yaml`). They do
nothing until you run them. Add your artwork under `assets/launcher/` per
the TODO header in each file, then:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Delete either config file if you're not ready to ship that yet.

## Further reading

- `docs/ARCHITECTURE.md` — the full picture: the philosophy, what `app/` /
  `core/` / `features/` are each for, how they communicate, the rules,
  and how to decide where a new piece of code belongs. Read this once
  before you add your second feature.
- `docs/decisions/` — one ADR per deliberate architectural choice. Read
  one only when you need the *why*, not the *how*.
- `docs/PWA-CHECKLIST.md` — if you ship a web target. What a
  mobile-first Flutter app gets wrong in a browser tab (viewport meta,
  text-scale clamp, `GoRouterState.extra` on reload, device id, local
  storage). Skip it for a mobile-only app.
- `docs/MIGRATION-PLAYBOOK.md` — if you're moving an existing app onto
  this structure. The mechanical port, plus the three follow-up ADRs
  every migration onto this kit has ended up writing.
