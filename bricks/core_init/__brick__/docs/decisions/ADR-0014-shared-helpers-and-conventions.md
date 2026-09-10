# ADR-0014: Small shared helpers and folder conventions carried back from downstream projects

## Status

Accepted

## Context

Three separate apps have been migrated onto this kit. A comparison of
their `lib/` trees turned up a handful of things each one rebuilt from
scratch, independently, without coordinating. None were big enough to be
their own ADR at the time; together they are worth landing so the fourth
migration doesn't rewrite them too.

## Decision

### `confirmDialog()` ships as a shared helper

`lib/app/widgets/confirm_dialog.dart`:
`Future<bool> confirmDialog(context, {title, message, confirmLabel,
cancelLabel})`. Two of the three apps wrote a function with this exact
signature and the same contract: it resolves to `true` **only** on an
explicit confirm tap, and every dismissal path (cancel, barrier, back)
resolves to `false`, so a caller treats a falsy result as "don't
proceed". Both wrote nearly the same doc comment explaining that
contract.

It is a plain, unstyled `AlertDialog`. It is here as a control-flow
convenience — the "dismiss means no" contract is the point — not as a
design component, so it does not conflict with ground rule 4. The
`example_feature` logout button uses it, so it is a live reference, not
dead code.

### `unexpectedError()` ships in `core/logging/`

`lib/core/logging/unexpected_error.dart`:
`Result<Failure, T> unexpectedError<T>(Logger, String context, Object
error, StackTrace, {Failure failure = const UnknownFailure()})`. Logs and
returns a generic failure.

ADR-0011 already established that a repository's generic `catch (e,
stackTrace)` branch must log before returning `UnknownFailure`, and
suggested a small private helper once a class has two or more such
catches. Every downstream project ended up promoting that private helper
to a shared `core/` function anyway. The kit now ships it, and
`example_feature_repository_impl.dart` uses it.

### `lib/core/device/` is the home for device-level infrastructure

Two of the three apps independently created a `core/device/` directory —
one for a device-metadata provider (model, OS version, app version,
attached to network requests), one for a random device-id provider and a
platform-support classifier. The kit ships nothing here (a fresh project
has no such need), but the convention is now documented: anything that
reads device or platform identity is `core/device/`, injectable, no
screen — the same category as `core/services/`.

### Typed asset paths, not bare strings

Two apps created a constants file for asset paths (`app/assets.dart` /
`core/constants/image_asset.dart`) rather than scattering
`'assets/images/…'` string literals through widgets. Documented as the
convention; nothing to ship until a project has assets.

### A date-formatting helper is expected, not provided

Two apps wrote a thin wrapper over `intl`'s `DateFormat` (a
`date_format_util.dart` / `indo_datetime.dart`). The kit does not depend
on `intl` and ships no such helper — adding one with no call site would
be dead weight — but a project that formats dates should put its wrapper
in `core/`, not inline in widgets.

### `flutter_launcher_icons` + `flutter_native_splash` are wired, not run

Both mobile-shipping downstream apps added these two generators and a
config file each. They are now `dev_dependencies` with a
`flutter_launcher_icons.yaml` / `flutter_native_splash.yaml` at the repo
root, each carrying a TODO header. They are inert until a developer
supplies artwork and runs the generator — `flutter pub get` and
`flutter test` do not touch them.

## Alternatives considered

- **Ship the full shared-widget set** (`AppButton`, `AppCard`,
  `AppTextField`, a snackbar helper, a responsive util) that all three
  apps built: rejected. Those carry real styling decisions — button
  variants, card elevation, input borders — which is the visual-identity
  opinion ground rule 4 exists to keep out. `confirmDialog` is the
  exception only because it can be genuinely styleless. The *list* of
  widgets to expect is named in `docs/ARCHITECTURE.md` instead.
- **Ship a placeholder launcher icon PNG** so the generators run
  out of the box: rejected — a placeholder icon is artwork, and a
  generated project with a stranger's placeholder icon baked into every
  platform is worse than one with a TODO.
- **Add `intl` and a date helper now**: rejected — no call site in a
  fresh project; it would be an abstraction ahead of its need.

## Consequences

- `lib/app/widgets/` now exists in a generated project (previously it was
  a documented-but-empty location). It holds exactly one file.
- A new repository's unexpected-error branch should call
  `unexpectedError(_logger, ...)` rather than re-inlining the log +
  `Result.failure`.
- `pubspec.yaml` has two more `dev_dependencies`. They pull no runtime
  code into the app.
