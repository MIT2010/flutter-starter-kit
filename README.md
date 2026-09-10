# Flutter Starter Kit

**A real architecture on day one — the layering, error handling, DI, networking,
and the known-bug guards are already decided and tested.**

Two [Mason](https://pub.dev/packages/mason_cli) bricks: one generates a
complete single-package project, the other scaffolds every feature into it.
Opinionated where it prevents bugs, deliberately silent on visual identity.

![Flutter 3.44.7 pinned](https://img.shields.io/badge/Flutter-3.44.7%20pinned-02569B?logo=flutter&logoColor=white)
![Tooling: Mason](https://img.shields.io/badge/tooling-Mason-F9A825)
![Lints: flutter_lints](https://img.shields.io/badge/lints-flutter__lints-4BC0F5)
![ADRs: 16](https://img.shields.io/badge/ADRs-16-6E56CF)
![PRs welcome](https://img.shields.io/badge/PRs-welcome-2EA043)

---

## Is this for you?

**Use it** when you're starting a new production Flutter app and want the
architecture settled — one feature shape everywhere, failures as values, a
generator for the boilerplate, and a handful of well-known production bugs
prevented by structure rather than by review.

**Skip it** if you want a UI kit, a component library, or a design system —
it ships none of those on purpose (`lib/app/theme/` is a bare placeholder).
Also skip it if you want a minimal "hello world"; this has opinions.

## Quickstart

Install the Mason CLI (`dart pub global activate mason_cli`), then:

```bash
git clone https://github.com/MIT2010/flutter-starter-kit
cd flutter-starter-kit
mason get
mason make core_init -o ../my_app --project_name my_app --description "My app"
cd ../my_app
```

That directory is a runnable project.
[`docs/QUICKSTART.md`](bricks/core_init/__brick__/docs/QUICKSTART.md) inside it
takes over — `flutter pub get`, code-gen, `flutter run`. The first screen is a
"You're all set" page that fetches live data, so one run confirms the whole
data → domain → presentation → `Result` path works.

Add a feature from the project root:

```bash
mason make feature --feature_name payments
```

All three layers, the DI annotations, a wired `GoRoute`, and test skeletons in
one pass. `project_name` is read from `pubspec.yaml`, so you don't pass it
([ADR-0015](bricks/core_init/__brick__/docs/decisions/ADR-0015-feature-brick-derives-project-name.md)).

> To run `mason make` from any directory without cloning first, see
> [Advanced install](#advanced-install).

## What you get

`mason make core_init` produces a project that already has:

| Area | What's in the box |
|---|---|
| **Structure** | `data / domain / presentation` per feature — one shape, no flat variant. Single package by default. |
| **Errors** | `Result<Failure, S>` — no exceptions reach the UI, no `null`-means-failure. A `Failure` hierarchy with user-safe messages. |
| **State** | Cubit + `flutter_bloc`, one sealed state per feature. `emit`-after-`close` guards baked into the templates. |
| **DI** | `get_it` + `injectable` — every registration generated, never hand-typed. |
| **Network** | One shared `Dio`. Auth, redacted-logging, and session-expiry interceptors, all attached, with a test that fails if one isn't. A refresh-token interceptor sits alongside as a one-file swap. |
| **Routing** | One `go_router` with a cold-start-safe auth guard (tells "not checked yet" from "logged out"), plus a `requireExtra<T>()` guard for reload-safe `extra`. |
| **Storage** | `hive_ce` behind a thin `HiveClient`. A discoverable temp-file cleanup path. |
| **Logging** | Structured `logger`, a `BlocObserver` + `NavigatorObserver` for app-flow tracing — type names only, never state contents. |
| **Config** | Per-environment values via `--dart-define-from-file` JSON, defaulting so bare `flutter run` works. |
| **Tests** | Golden tests that load real fonts, a cubit + widget test per feature, the kit's own infrastructure tested too. CI runs it all. |
| **Docs** | 16 ADRs, a full `ARCHITECTURE.md`, a migration playbook, a PWA checklist — all shipped into the generated project. |

**What it does not ship:** a design system, a component library, a palette, or a
font. `lib/app/theme/` is a replaceable `ColorScheme.fromSeed` placeholder plus
one valueless `AppSpacing` scale (`context.spacing.md`) — a consistency
mechanism, not a look
([ADR-0013](bricks/core_init/__brick__/docs/decisions/ADR-0013-spacing-scaffold.md)).

## Architecture, in one paragraph

Progressive disclosure. You start at Layers 0–3: a single package with the
list above. Layer 4 — a Melos multi-package split — exists only as an opt-in
`upgrade_to_monorepo` migration brick (not built yet), and it is justified
only when two or more real apps share code, never "we might need it one day".
Nothing adds multi-package structure by hand.

The full reasoning, the `app` / `core` / `features` split, how the layers
communicate, and a guide for deciding where new code belongs are in
[`ARCHITECTURE.md`](bricks/core_init/__brick__/docs/ARCHITECTURE.md).

## SDK version

`.fvmrc` pins Flutter `3.44.7`, and CI builds against that pin. The golden
tests and the `freezed` / `injectable_generator` versions are tied to one
analyzer, so the SDK can't float. [FVM](https://fvm.app) is the convenient way
to match the pin — it isn't required, and nothing shells out to `fvm`. Bumping
it is routine but coordinated: edit `.fvmrc`, re-run code-gen and
`flutter test --update-goldens`
([ADR-0016](bricks/core_init/__brick__/docs/decisions/ADR-0016-flutter-sdk-pin.md)).

## Repo layout

```
flutter-starter-kit/
├── mason.yaml                    # registers both bricks for local use
├── bricks/
│   ├── core_init/__brick__/      # the generated project, verbatim + templated
│   └── feature/
│       ├── __brick__/            # per-feature file templates
│       └── hooks/
│           ├── pre_gen.dart      # derives project_name from pubspec.yaml
│           └── post_gen.dart     # wires the new route into app/router.dart
└── docs/proposals/              # cross-project findings staged for the kit
```

Docs live inside the `core_init` brick, so every generated project carries its
own copy:

| Doc | For |
|---|---|
| [`docs/QUICKSTART.md`](bricks/core_init/__brick__/docs/QUICKSTART.md) | clone → running app |
| [`docs/ARCHITECTURE.md`](bricks/core_init/__brick__/docs/ARCHITECTURE.md) | the full picture, and where new code goes |
| [`docs/MIGRATION-PLAYBOOK.md`](bricks/core_init/__brick__/docs/MIGRATION-PLAYBOOK.md) | moving an existing app onto this structure |
| [`docs/PWA-CHECKLIST.md`](bricks/core_init/__brick__/docs/PWA-CHECKLIST.md) | what a mobile-first app gets wrong on the web |
| [`docs/decisions/`](bricks/core_init/__brick__/docs/decisions/) | one ADR per deliberate choice |

## Advanced install

### Run `mason make` from any directory

The quickstart needs `mason.yaml` in the current directory. Register the bricks
globally once to skip that — from the git repo (portable):

```bash
mason add -g core_init --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/core_init
mason add -g feature   --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/feature
```

…or from a local clone (no network per use; simplest for a private repo):

```bash
git clone https://github.com/MIT2010/flutter-starter-kit  ~/src/fsk
mason add -g core_init --path ~/src/fsk/bricks/core_init
mason add -g feature   --path ~/src/fsk/bricks/feature
```

Then `mason make core_init -o <dir> …` and `mason make feature` work anywhere.
`mason list -g` / `mason remove -g <name>` manage them; a `--git-url` install
pins to a commit (re-run `mason add -g` to advance), a `--path` install tracks
the clone.

### Windows

Mason's git-brick cache path (`%LOCALAPPDATA%\Mason\Cache\git\<repo>_<base64
url>_<sha>\…`) is long enough that, with a long user name, `mason get` /
`mason add --git-url` can exceed the 260-character path limit and fail with
`PathNotFoundException`. Fix: `setx MASON_CACHE C:\mc` and open a new terminal,
or use the `--path` install form above. macOS and Linux are unaffected.

### Private repo

Mason runs `git clone`, so it uses your git credential helper — run
`gh auth setup-git`, or use an `ssh` URL with a key on your account. Don't put a
token in the URL (it lands in the cache path); the `--path` form avoids the
question entirely.

## License

No license file is bundled — add one before sharing the kit publicly. Code you
generate with `core_init` / `feature` is your own project's, under whatever
license you pick for it.
