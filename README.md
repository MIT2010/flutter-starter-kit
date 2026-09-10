# Flutter Starter Kit

A progressive-disclosure Flutter starter kit, distributed as a pair of
[Mason](https://pub.dev/packages/mason_cli) bricks — not a template you
copy by hand.

## What's here

- **`bricks/core_init`** — generates a complete new project: single-package
  Layer 0 architecture (`data/domain/presentation` per feature, `Result<F,S>`
  error handling, get_it + injectable DI, go_router with a cold-start-safe
  auth guard, a shared Dio client with attached auth/logging/session-expiry
  interceptors (a refresh-token interceptor ships alongside as an opt-in
  swap — see ADR-0012), hive_ce local storage, a generic theme scaffold, a built-in
  `auth` feature (locally-simulated login by default, no backend required —
  ADR-0007) plus an `example_feature` reference for a real network-backed
  read, unit/widget/golden tests, CI, and ADR docs explaining every
  deliberate architectural choice.
- **`bricks/feature`** — scaffolds a new feature (all three layers, DI
  registration, a route entry) into a project `core_init` already generated.

Neither brick ships an opinionated design system or component library.
The theme scaffold (`bricks/core_init/__brick__/lib/app/theme/`) is a
replaceable placeholder `ColorScheme` plus one valueless `AppSpacing`
step scale read via `context.spacing` — a consistency mechanism, not a
visual identity. See ADR-0013.

## Using it

**Generate into a separate directory — never into this repo itself.**
`mason make` will happily overwrite whatever's in its output target, and
this repo's own root is the brick *source*, not a place to generate into.

```bash
mason get
mason make core_init -o ../my_new_app --project_name my_new_app
cd ../my_new_app
cat docs/QUICKSTART.md   # onboarding path for the generated project itself
```

To scaffold a feature into an existing generated project:

```bash
mason make feature -o ../my_new_app --feature_name payments --project_name my_new_app
```

(A *generated* project's own `mason make feature` resolves the `feature`
brick from this repo over git — see
`bricks/core_init/__brick__/docs/decisions/ADR-0006-*.md`.)

### Windows: point `MASON_CACHE` at a short path

Mason caches a git-sourced brick under
`%LOCALAPPDATA%\Mason\Cache\git\<repo>_<base64 url>_<40-char sha>\…`. That
prefix is ~180 characters before the brick's own files, so on Windows —
especially with a long user name — `mason add --git-url` / `mason get`
for these bricks blows past the 260-character path limit and fails with
`PathNotFoundException: Directory listing failed`.

Fix: move the cache somewhere short, once:

```bat
setx MASON_CACHE C:\mc
```

Open a new terminal (so it picks up the variable), then `mason add` /
`mason get` / `mason make` all work. Without it, use a local clone and a
`--path` source instead of `--git-url` — `git clone` this repo somewhere
short, then `mason add core_init --path <clone>\bricks\core_init`. macOS
and Linux are unaffected.

## Understanding the generated project

`bricks/core_init/__brick__/docs/ARCHITECTURE.md` is the full walkthrough
of what `core_init` produces: the philosophy, the `app/` / `core/` /
`features/` split, how the layers communicate, the rules, and how to
decide where new code belongs. It ships into every generated project's
`docs/` too.

## Layer 4 (multi-package monorepo) — not yet built

Strictly opt-in, triggered by an explicit `upgrade_to_monorepo` migration
brick — never the default. Not started until Phases 1–3 here are confirmed
working and a user explicitly asks for it (see `CLAUDE.md`).

## Repo layout

```
flutter-starter-kit/
├── mason.yaml              # registers both bricks for local development
├── bricks/
│   ├── core_init/
│   │   ├── brick.yaml
│   │   └── __brick__/      # the generated project's full content
│   └── feature/
│       ├── brick.yaml
│       ├── __brick__/      # per-feature file templates
│       └── hooks/
│           └── post_gen.dart   # wires the new route into app/router.dart
└── docs/proposals/         # cross-project findings staged for the kit
```

`CLAUDE.md` (the spec this repo was built against, plus agent notes) is
kept locally but git-ignored — it isn't part of the distributed kit.
