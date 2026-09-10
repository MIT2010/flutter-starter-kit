# Flutter Starter Kit

**A progressive-disclosure Flutter starter kit — a real architecture on day one, without the ceremony.**

Two [Mason](https://pub.dev/packages/mason_cli) bricks generate a complete,
tested, single-package project and scaffold every feature into it. Opinionated
where it prevents bugs, deliberately silent on visual identity.

![Flutter 3.44.7 (pinned)](https://img.shields.io/badge/Flutter-3.44.7%20pinned-02569B?logo=flutter&logoColor=white)
![Tooling: Mason](https://img.shields.io/badge/tooling-Mason-F9A825)
![Lints: flutter_lints](https://img.shields.io/badge/lints-flutter__lints-4BC0F5)
![ADRs: 15](https://img.shields.io/badge/ADRs-15-6E56CF)
![PRs welcome](https://img.shields.io/badge/PRs-welcome-2EA043)

---

## What you get

`mason make core_init` produces a project that already has:

| Area | What's in the box |
|---|---|
| **Structure** | `data / domain / presentation` per feature — one shape, no flat variant. Single package (Layer 0); the monorepo split is opt-in. |
| **Errors** | `Result<Failure, S>` — no exceptions cross into the UI, no `null`-means-failure. A `Failure` hierarchy with user-safe messages. |
| **State** | Cubit + `flutter_bloc`, one sealed state class per feature. `emit`-after-`close` guards baked into the templates. |
| **DI** | `get_it` + `injectable` — every registration generated, never hand-typed. |
| **Network** | One shared `Dio`. Auth, redacted-logging, and session-expiry interceptors, all attached, with a test that fails if one isn't. A refresh-token interceptor ships alongside as a one-file swap. |
| **Routing** | One `go_router` with a cold-start-safe auth guard (tells "not checked yet" from "logged out"), plus a `requireExtra<T>()` guard for reload-safe `extra`. |
| **Storage** | `hive_ce` behind a thin `HiveClient`. A discoverable temp-file cleanup path. |
| **Logging** | Structured `logger`, a `BlocObserver` and a `NavigatorObserver` for app-flow tracing — type names only, never state contents. |
| **Config** | Per-environment values via `--dart-define-from-file` JSON, defaulting so bare `flutter run` works. |
| **Tests** | Golden tests that load real fonts, a cubit + widget test per feature, and the kit's own infrastructure tested too. |
| **Docs** | 15 ADRs, a full `ARCHITECTURE.md`, a migration playbook, a PWA checklist. |

**What it does not ship:** a design system, a component library, a palette, or
a font. `lib/app/theme/` is a replaceable `ColorScheme.fromSeed` placeholder
plus one valueless `AppSpacing` scale (`context.spacing.md`) — a consistency
mechanism, not a look. See [ADR-0013](bricks/core_init/__brick__/docs/decisions/ADR-0013-spacing-scaffold.md).

## Quickstart

Install the Mason CLI (`dart pub global activate mason_cli`), then:

```bash
git clone https://github.com/MIT2010/flutter-starter-kit
cd flutter-starter-kit
mason get
mason make core_init -o ../my_app --project_name my_app --description "My app"
cd ../my_app
```

That directory is a runnable project. Its own
[`docs/QUICKSTART.md`](bricks/core_init/__brick__/docs/QUICKSTART.md) takes it
from there — `flutter pub get`, code-gen, `flutter run`.

The generated project pins its Flutter SDK in `.fvmrc` (`3.44.7`), and its
CI builds against that pin — the golden tests and the `freezed` /
`injectable_generator` versions are tied to a specific analyzer, so the
SDK can't float. [FVM](https://fvm.app) is the easy way to match it but
isn't required; nothing shells out to `fvm`. See
[ADR-0016](bricks/core_init/__brick__/docs/decisions/ADR-0016-flutter-sdk-pin.md).

To add a feature, from the project root:

```bash
mason make feature --feature_name payments
```

All three layers, the DI annotations, a wired `GoRoute`, and test skeletons —
in one pass. `project_name` is read from `pubspec.yaml`, so you don't pass it
([ADR-0015](bricks/core_init/__brick__/docs/decisions/ADR-0015-feature-brick-derives-project-name.md)).

> Prefer running `mason make` from anywhere without cloning first? See
> [Advanced install](#advanced-install-global-windows-private-repos) below.

## The idea

Most Flutter architecture decisions are really about scale, so this kit picks a
default and defers the rest. You start with Layers 0–3 (single package, the
list above). Layer 4 — a Melos multi-package split — exists but stays off until
a separate migration brick turns it on, which is only justified once two real
apps share code.

The full reasoning, the `app` / `core` / `features` split, how the layers talk,
and a guide for deciding where new code belongs are in
[`ARCHITECTURE.md`](bricks/core_init/__brick__/docs/ARCHITECTURE.md) — it ships
into every generated project too.

## Repo layout

```
flutter-starter-kit/
├── mason.yaml                    # registers both bricks for local use
├── bricks/
│   ├── core_init/
│   │   ├── brick.yaml
│   │   └── __brick__/            # the generated project, verbatim + templated
│   └── feature/
│       ├── brick.yaml
│       ├── __brick__/            # per-feature file templates
│       └── hooks/
│           ├── pre_gen.dart      # derives project_name from pubspec.yaml
│           └── post_gen.dart     # wires the new route into app/router.dart
└── docs/proposals/              # cross-project findings staged for the kit
```

Documentation lives inside the `core_init` brick so a generated project carries
its own copy:

| Doc | For |
|---|---|
| [`docs/QUICKSTART.md`](bricks/core_init/__brick__/docs/QUICKSTART.md) | clone → running app |
| [`docs/ARCHITECTURE.md`](bricks/core_init/__brick__/docs/ARCHITECTURE.md) | the full picture, and where new code goes |
| [`docs/MIGRATION-PLAYBOOK.md`](bricks/core_init/__brick__/docs/MIGRATION-PLAYBOOK.md) | moving an existing app onto this structure |
| [`docs/PWA-CHECKLIST.md`](bricks/core_init/__brick__/docs/PWA-CHECKLIST.md) | what a mobile-first app gets wrong on the web |
| [`docs/decisions/`](bricks/core_init/__brick__/docs/decisions/) | one ADR per deliberate choice |

## Advanced install: global, Windows, private repos

### Run `mason make` from anywhere

The quickstart needs `mason.yaml` in the current directory. Register the bricks
globally once to skip that.

From the git repo (portable — any machine with GitHub access):

```bash
mason add -g core_init --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/core_init
mason add -g feature   --git-url https://github.com/MIT2010/flutter-starter-kit --git-path bricks/feature
```

Or from a local clone (no network per use; sidesteps the Windows path issue
below; simplest for a private repo — you clone once with your own credentials):

```bash
git clone https://github.com/MIT2010/flutter-starter-kit  ~/src/fsk
mason add -g core_init --path ~/src/fsk/bricks/core_init
mason add -g feature   --path ~/src/fsk/bricks/feature
```

Then, from anywhere:

```bash
mkdir my_app && cd my_app
mason make core_init -o . --project_name my_app --description "…"
mason make feature --feature_name payments        # from a project root
```

`mason list -g` and `mason remove -g <name>` manage them. A `--git-url` install
pins to the commit it resolved (re-run `mason add -g` to advance it); a
`--path` install tracks the clone (`git pull` and you're current).

### Windows: point `MASON_CACHE` at a short path

Mason caches a git-sourced brick under
`%LOCALAPPDATA%\Mason\Cache\git\<repo>_<base64 url>_<40-char sha>\…` — a ~180-
character prefix before the brick's own files. On Windows, especially with a
long user name, `mason add --git-url` / `mason get` then exceeds the
260-character path limit and fails with `PathNotFoundException: Directory
listing failed`.

Fix it once:

```bat
setx MASON_CACHE C:\mc
```

Open a new terminal so it picks up the variable. Or use the `--path` install
form above, which never touches that long cache path. macOS and Linux are
unaffected.

### Private repo

Mason shells out to `git clone`, so it uses your git credential helper —
nothing mason-specific. `--git-url` against a private repo works wherever
`git clone <that url>` works: run `gh auth setup-git`, or use an `ssh` URL with
a key on your account. Don't put a token in the URL — it lands in mason's cache
path. The `--path` form avoids the question entirely.

## Layer 4 (multi-package monorepo)

Not built yet. It will be strictly opt-in, triggered by an explicit
`upgrade_to_monorepo` migration brick — never the default. The trigger is "two
or more real apps sharing code", not "we might need it one day".

## License

No license file is bundled — add one before sharing the kit publicly. Code you
generate with `core_init` / `feature` is your own project's, under whatever
license you choose for it.
