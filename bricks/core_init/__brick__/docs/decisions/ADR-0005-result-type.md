# ADR-0005: Hand-written Result<F, S>, not freezed

## Status

Accepted

## Context

Every repository method that can fail must return `Result<Failure, S>`
rather than throwing or returning `null`. This type needs `Result.success(...)`
/ `Result.failure(...)` factory constructors and to support pattern matching
from any file (cubits match on it directly).

## Decision

`lib/core/result.dart` is a plain Dart 3 `sealed class` with two public
variant classes (`Success<F, S>`, `ResultFailure<F, S>`) and a `fold()`
helper — no `freezed` annotation, no code generation.

## Alternatives considered

- **`freezed` sealed union** (matching the pattern used for
  `ExampleFeatureState`): rejected for this specific type. `Result` needs no
  `copyWith`, no `toJson`, and no deep equality beyond what a plain class
  already gives it for this use case — pulling in codegen for it would add a
  build_runner dependency to the single most foundational type in the app
  for no real benefit. Feature-level state classes (which *do* benefit from
  `copyWith`/equality/pattern-matching sugar) still use `freezed` — see
  `example_feature_state.dart`.

## Consequences

- `Success`/`ResultFailure` are deliberately public (not
  library-private/`_`-prefixed) specifically so `case Success(:final value):`
  pattern matching works from any importing file, not just `fold()`.

## Addendum: the `Failure` hierarchy and `MessageFailure`

`lib/core/failure.dart` is the `F` in `Result<Failure, S>`. The generic
types (`NetworkFailure`, `ServerFailure`, `CacheFailure`,
`UnauthorizedFailure`, `UnknownFailure`) all carry a fixed, hardcoded,
user-safe message — a repository maps a raw error onto one of them and the
raw text never reaches the UI.

`MessageFailure` is a deliberate exception to that. Real backends
observed across projects built on this kit routinely author their
`message`/`msg` field as display copy, confirmed with the backend's own
maintainer. Discarding that for a generic string makes the product worse,
not safer. `MessageFailure` lets a repository pass such a string through
*when it is known to be display-authored* — its own doc comment spells
out exactly what may and may not go into it. Anything exception-shaped,
malformed, or unexpected still goes through `mapDioError` to a generic
type. Keep `MessageFailure` call sites few and obvious, or the "no raw
backend strings in the UI" guarantee erodes.
