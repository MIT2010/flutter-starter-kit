# ADR-0004: Pinning freezed to stable 3.x and injectable_generator to 3.0.2

## Status

Accepted

## Context

Package versions were resolved live against pub.dev (`flutter pub add`), not
hand-pinned from memory, per project policy. Two resolutions surfaced a real
ecosystem conflict rather than a straightforward "latest":

- `flutter pub add freezed` resolved to `4.0.0-dev.3`, a **prerelease** —
  because `injectable_generator`'s latest (`3.1.1`, and `3.1.0` before it)
  transitively depends on `lean_builder ^1.2.0`, which requires
  `analyzer ^13.0.0`. Stable `freezed` (`3.2.5`) caps at `analyzer <11.0.0`
  and hasn't shipped a stable release supporting `analyzer 13` yet — its own
  `3.2.6-dev.1` and `4.0.0-dev.*` lines are where that migration is
  happening, still in prerelease as of this writing.
- `injectable_generator 3.0.2` depends on `lean_builder ^0.1.10`, which is
  compatible with `analyzer` in the `10.x–12.x` range — overlapping with
  `freezed 3.2.5`'s `>=9.0.0 <11.0.0` requirement at analyzer `10.x`.

## Decision

Pin:
- `freezed: 3.2.5` (latest **stable**, not the `4.0.0-dev.*` prerelease)
- `injectable_generator: 3.0.2` (one minor behind the latest `3.1.1`, but
  the newest version that stays on a stable-compatible `analyzer` range)

resolving to `analyzer 10.2.0` — a fully stable dependency graph with no
prereleases.

## Alternatives considered

- **Use `freezed: 4.0.0-dev.3`**: would let `injectable_generator` stay on
  latest, but ships a prerelease codegen dependency in a starter kit meant
  to be a stable baseline for new projects — rejected.

## Consequences

- Revisit this pin once `freezed` ships a stable release supporting
  `analyzer ^13.0.0` (watch the `3.2.6` / `4.0.0` stable channel) — at that
  point `injectable_generator` can move back to latest too.
- `dart run build_runner build` currently reports "14 packages have newer
  versions incompatible with dependency constraints" — expected, and not a
  bug: those are the packages held back by this exact pin.
