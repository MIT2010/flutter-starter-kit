# ADR-0016: `.fvmrc` pins the Flutter SDK, and CI uses that pin

## Status

Accepted

## Context

The kit shipped `.fvmrc` (`{"flutter": "3.44.7"}`) but nothing referenced
it. Worse, `.github/workflows/ci.yml` ran `subosito/flutter-action` with
`channel: stable` — whatever the latest stable happened to be at CI run
time. So the project carried three disagreeing notions of "which SDK":
`.fvmrc` said one exact build, CI said "latest stable", and
`pubspec.yaml`'s `sdk:` constraint said only a loose Dart range.

That gap matters here specifically:

- **ADR-0004** pins `freezed: 3.2.5` and `injectable_generator: 3.0.2` to
  a stable analyzer graph. Those versions were resolved against a
  particular SDK's bundled Dart/analyzer. A CI SDK that differs from the
  developer's can resolve a different analyzer and break — or silently
  drift from — code generation.
- **Golden tests** render differently across SDK versions (font metrics,
  Skia/Impeller changes). A golden captured locally on the pinned SDK
  will mismatch a CI run on a newer one.

## Decision

`.fvmrc` is the single source of truth for the Flutter version.

- **`ci.yml`** uses `subosito/flutter-action` with
  `flutter-version-file: .fvmrc` — it reads the `flutter` key from that
  file. CI and a local FVM setup now build with the identical SDK.
- The pinned version is **"verified against", not "locked forever"**.
  Bumping it is a normal maintenance action, not a violation — but it is
  a coordinated one:
  1. edit `.fvmrc`,
  2. `dart run build_runner build --delete-conflicting-outputs`,
  3. `flutter test --update-goldens`,
  4. confirm `pubspec.yaml`'s `freezed` / `injectable_generator` pins
     still resolve on the new SDK's analyzer (revisit ADR-0004 if not).
- **FVM is not required to use the kit.** `.fvmrc` is a hint FVM reads;
  a matching `flutter` on `PATH` works identically. Nothing in the
  generated project invokes `fvm`.

## Alternatives considered

- **Leave CI on `channel: stable`**: rejected — it's the source of the
  local/CI drift, and it makes the golden tests and the ADR-0004 pins
  unreliable in CI, which is exactly where they're supposed to be a
  safety net.
- **Drop `.fvmrc`, rely only on `pubspec.yaml`'s `sdk:` range**: rejected
  — a Dart range doesn't pin a Flutter version, and the golden/analyzer
  coupling above needs an exact one.
- **Pin only a minor (`3.44.x` / a channel), not a patch**: a reasonable
  middle ground, but a bare exact version is what FVM and
  `flutter-version-file` consume most predictably, and the "bump
  deliberately" workflow above is cheap enough that a floating patch
  isn't worth the small extra non-determinism.

## Consequences

- A contributor without the pinned SDK installed sees FVM (or their SDK
  manager) fetch it, or a version-mismatch warning from `flutter` — not a
  silent build on the wrong toolchain.
- CI is deterministic across time: a run today and a run in six months
  use the same SDK unless `.fvmrc` changed.
- Upgrading Flutter is a small, visible PR (`.fvmrc` + regenerated code +
  updated goldens), reviewable as one unit.
