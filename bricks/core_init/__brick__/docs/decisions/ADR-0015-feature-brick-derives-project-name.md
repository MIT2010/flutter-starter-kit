# ADR-0015: The `feature` brick derives `project_name`, it doesn't ask for it

## Status

Accepted

## Context

`mason make feature` scaffolds a feature into an existing project. Its
generated test files need `package:<project>/…` imports, so the brick
needs the project's Dart package name.

Originally `project_name` was a brick var with a prompt and a `my_app`
default. Every run asked for it, and its own ADR-0006 note warned it
"must match `pubspec.yaml` -> name exactly" — a value the user has to
type correctly on every feature, that is already written down one file
away. A typo produced a feature whose tests import a package that doesn't
exist.

Mason prompts for **every** declared var that isn't passed on the command
line, whether or not it has a `prompt:` field, and hooks run *after* that
prompt — so there is no way to keep `project_name` as a var and also stop
it being asked.

## Decision

`project_name` is **not** a brick var. `bricks/feature/hooks/pre_gen.dart`
resolves it before generation and puts it in the hook context:

1. `./pubspec.yaml` in the current directory — its `name:`. This is the
   normal case: `mason make feature` run from a project root.
2. the `FEATURE_PROJECT_NAME` environment variable — for generating into
   a fresh directory with `-o`, where there is no `./pubspec.yaml` (the
   starter kit's own Checkpoint 2 verification does this).
3. neither → the hook prints an explanatory error and stops. A silent
   `my_app` fallback would produce tests that don't compile.

`feature_name` is still a prompted var — that one genuinely has to be
supplied.

## Consequences

- The common case is now `mason make feature --feature_name <name>`, run
  from the project root. Nothing else to pass, nothing to get wrong.
- Generating from outside a project (`-o <dir>`) needs
  `FEATURE_PROJECT_NAME=<pkg>` in the environment. Documented in
  QUICKSTART, the README, and ADR-0006.
- The `feature` brick now has a `pre_gen.dart` hook alongside its
  existing `post_gen.dart` (route wiring). Both compile on first use.
- `mason make feature` reads `./pubspec.yaml` relative to the current
  working directory — the same assumption `post_gen.dart` already makes
  for `lib/app/router.dart`. Run it from the project root.
