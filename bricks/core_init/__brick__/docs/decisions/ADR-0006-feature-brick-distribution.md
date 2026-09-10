# ADR-0006: The `feature` brick ships via git reference, not a bundled copy

## Status

Accepted

## Context

Every feature must be scaffolded via the `feature` Mason brick, never
hand-typed (ground rule 3). For a *generated* project to run
`mason make feature` on its own, its `mason.yaml` needs to point at the
brick's source somehow.

Embedding a raw copy of `bricks/feature/` inside `bricks/core_init/__brick__/`
was tried and rejected: Mason templates every file (and directory name)
under `__brick__/` using `core_init`'s own variables. The `feature` brick's
own template files contain mustache tags for `feature_name` (in
`snakeCase()` for directory names, `pascalCase()` for class names) —
variables `core_init` doesn't define. Nesting them would have silently
rendered those tags as empty strings during `mason make core_init`,
corrupting the embedded copy before a user ever touched it.

(This ADR file itself is subject to that same templating pass. It
deliberately avoids writing a literal mustache tag anywhere above, because
a `feature_name`-shaped tag in this prose would render to an empty string
in every generated project's copy of this document — the exact failure
being described.)

## Decision

`lib/app/../mason.yaml` (generated at the project root) registers `feature`
via a **git source** (`git: {url: ..., path: bricks/feature}`), not a local
path or a bundled `.tar` artifact. This is the standard, portable Mason
mechanism for referencing a brick that lives in a separate repo.

The URL in the generated `mason.yaml`
(`https://github.com/MIT2010/flutter-starter-kit.git`) points at this
starter kit's own repo. If you fork or re-host the kit, change it to your
own remote.

## Alternatives considered

- **`mason bundle`**: compiles a brick into a single opaque artifact that
  *could* safely sit inside another brick's output without templating
  collisions (its content is encoded, not raw mustache source). Rejected
  for now as unnecessary complexity — this starter kit repo not yet having
  a git remote makes bundling moot until that's resolved anyway, and a git
  source is simpler to keep in sync (no re-bundle step when `feature`
  changes).
- **Relative local path** (e.g. `../flutter-starter-kit/bricks/feature`):
  only works if every generated project happens to sit at a fixed relative
  location next to a clone of this repo — not a safe assumption.

## Consequences

- `mason make feature` from inside a *generated* project resolves the
  brick from `github.com/MIT2010/flutter-starter-kit` over the network.
  For local development of the kit itself, and for Checkpoint 2
  verification, `feature` is invoked from a clone — either run from the
  scratch project's own root (`cd <scratch> && mason make feature
  --feature_name x`) or from anywhere with `FEATURE_PROJECT_NAME=<pkg>`
  set and `-o <scratch>` (the pre_gen hook needs one or the other —
  ADR-0015). Neither touches the git reference.
- A private fork must change the URL in
  `bricks/core_init/__brick__/mason.yaml` to its own remote, or
  `mason make feature` in downstream projects will hit the public repo.
- On Windows, `mason get` for this git source caches the brick under
  `%LOCALAPPDATA%\Mason\Cache\git\<repo>_<base64 url>_<sha>\…` — a ~180-
  character prefix that, with a long user name, pushes the brick's own
  files past the 260-character path limit (`mason` fails with
  `PathNotFoundException: Directory listing failed` while copying the
  clone into the cache). Workaround: `setx MASON_CACHE C:\mc` and use a
  fresh terminal. Not an issue on macOS/Linux. See `docs/QUICKSTART.md`.
