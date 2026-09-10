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

To scaffold a feature into an existing generated project, run from that
project's root:

```bash
cd ../my_new_app
mason make feature --feature_name payments
```

`project_name` is not passed — a pre_gen hook reads it from the project's
`pubspec.yaml` (ADR-0015). To generate from outside the project instead
(`-o <dir>`), set `FEATURE_PROJECT_NAME=<pkg>` in the environment.

(A *generated* project's own `mason make feature` resolves the `feature`
brick from this repo over git — see
`bricks/core_init/__brick__/docs/decisions/ADR-0006-*.md`.)

### Install the bricks globally (run from anywhere)

The flow above needs `mason.yaml` in the current directory. To run
`mason make core_init` / `mason make feature` from any directory, register
the bricks globally once.

From the git repo (portable — works on any machine with GitHub access):

```bash
mason add -g core_init --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/core_init
mason add -g feature   --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/feature
```

Or from a local clone (no network on each use; the only option that
sidesteps the Windows path-length issue below, and the simplest for a
private repo — you clone once with your own credentials):

```bash
git clone https://github.com/MIT2010/flutter-starter-kit  ~/src/fsk
mason add -g core_init --path ~/src/fsk/bricks/core_init
mason add -g feature   --path ~/src/fsk/bricks/feature
```

Then, from anywhere:

```bash
mkdir my_new_app && cd my_new_app
mason make core_init -o . --project_name my_new_app --description "…"
mason make feature --feature_name payments        # from a project root
```

Manage them with `mason list -g` and `mason remove -g <name>`. A
`--git-url` install pins to the commit it resolved; re-run `mason add -g`
to move it forward. A `--path` install tracks the clone — `git pull` and
you're current.

**Private repo:** mason shells out to `git clone`, so it uses your git
credential helper — nothing mason-specific. `--git-url` against a private
repo works wherever `git clone <that url>` works (run `gh auth setup-git`,
or use an `ssh` URL with a key on your account). Don't put a token in the
URL — it lands in mason's cache path. The `--path` form avoids the
question entirely.

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
`mason get` / `mason make` all work. Without it, use the `--path` install
form shown above (a local clone) instead of `--git-url` — it doesn't
touch the long cache path. macOS and Linux are unaffected.

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
