# ADR-0010: `presentation/pages/` and `*Page` naming, replacing `view`/`*Screen`

## Status

Accepted

## Context

Every feature's top-level routed widget lived under `presentation/view/`
and was named `<Feature>Screen` (`LoginScreen`, `ExampleFeatureScreen`,
and the equivalent in every feature the `feature` brick scaffolds).
Requested rename: the folder becomes `pages/` and the class becomes
`<Feature>Page`, for consistency with go_router's own vocabulary (a
`GoRoute` resolves to a "page" in go_router's/Navigator 2.0's own
terminology) and to avoid "screen" colliding with its other common,
unrelated meaning ("device screen size") elsewhere in a typical app.

## Decision

- `lib/features/<feature>/presentation/view/` → `presentation/pages/`,
  for both `example_feature` and `auth` (the two features `core_init`
  ships) and for the `feature` brick's own mustache template.
- `<Feature>Screen` → `<Feature>Page` throughout: `ExampleFeatureScreen`
  → `ExampleFeaturePage`, `LoginScreen` → `LoginPage`, and the `feature`
  brick's `{{feature_name.pascalCase()}}Screen` →
  `{{feature_name.pascalCase()}}Page`.
- Test files renamed to match: `example_feature_screen_test.dart` →
  `example_feature_page_test.dart` (including its golden reference image,
  `goldens/example_feature_screen_loaded.png` →
  `goldens/example_feature_page_loaded.png`), `login_screen_test.dart` →
  `login_page_test.dart`, and the `feature` brick's own
  `{{feature_name.snakeCase()}}_screen_test.dart` template →
  `{{feature_name.snakeCase()}}_page_test.dart`.
- `bricks/feature/hooks/post_gen.dart` — the route-wiring hook — updated
  to generate `presentation/pages/<feature>_page.dart` imports and
  `<Feature>Page` route builders instead of the old `view`/`Screen` shape.
- Docs updated to match: root `CLAUDE.md`'s target folder structure,
  `.claude/skills/flutter-starter-kit-conventions/references/
  folder-structure.md`, and `.claude/agents/feature-scaffolder.md`.

## Alternatives considered

- **Leave the naming as `view`/`*Screen`**: this was the original
  scaffold's convention, carried over without much deliberation; renamed
  on request once "page" was identified as the better fit for a
  go_router-based project specifically.

## Consequences

- Every project generated with `mason make core_init` from this point
  forward gets `pages/`/`*Page`, and every feature scaffolded via `mason
  make feature` into any project (old or new) also gets `pages/`/`*Page`
  — there's no version of this brick left producing the old shape, so
  there's no risk of a newly-generated feature reintroducing the
  inconsistency this rename removes.
- A project generated from an *older* copy of this starter kit (before
  this ADR) still has `view/`/`*Screen` — that's a pre-existing project's
  own decision at the time it was generated, not something this ADR
  retroactively changes; migrating such a project is a manual rename
  (or ask an agent to do it) the same way this change was made here.
