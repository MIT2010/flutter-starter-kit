# Proposal: spacing/status token scaffold, and a PWA checklist

Status: **fully applied (2026-09-09)**. B10/B11 shipped as docs;
B5 (`requireExtra`) and B6 (`AppSpacing` scaffold + ground rule 4
rescope) applied and verified end-to-end — `mason make core_init` →
`build_runner` → `flutter analyze` (clean) → `flutter test` **53/53**
(incl. the golden, unchanged), then `mason make feature payments` →
same chain **58/58**. Evidence in the vault:
`017 - Constraint-Driven Theming.md`, `018 - Shipping a Flutter PWA -
The Checklist.md`; more since, in `etle_mobile` ADR-0023 and
`siap_jalan` ADR-0013/0014/0015.

## B6 — ship the constraint mechanism, empty of opinion

**APPLIED 2026-09-09.** `lib/app/theme/app_theme_extension.dart` (the
throwaway placeholder) replaced by `app_spacing.dart` — `AppSpacing`
`ThemeExtension`, six-step scale, `context.spacing` accessor with an
`AppSpacing.standard()` fallback so a bare `MaterialApp` widget test
resolves it. `app_color_scheme.dart` doc comment strengthened (derive
from one seed, never a partial `ColorScheme`); status-colour tokens
stayed a documented pattern in the skill, not shipped code, as proposed.
`example_feature` and the `feature` brick's page template read
`context.spacing.md` (same pixel values — golden unchanged). New
`docs/decisions/ADR-0013-spacing-scaffold.md`; `CLAUDE.md` ground rule 4
+ the "Theme" behaviour line + `README.md` reworded to permit one
valueless scale; conventions skill Design-system section updated.

### What happened

`etle_mobile` ADR-0019 and `visitasi_sekolah_mengemudi` ADR-0019 are
separate visual-redesign passes, months apart. Both independently built:

- An `AppSpacing` `ThemeExtension` (`xs`=4 … `xxxl`=48), read via
  `context.spacing`, replacing ad hoc `EdgeInsets`/`SizedBox` numbers.
- A status-color token shape: one color+icon+label per lifecycle state,
  resolved from an unstructured backend string by keyword match with an
  explicit `unknown` fallback.
- `ColorScheme.fromSeed` for the whole scheme, never a hand-assigned
  partial `ColorScheme` that leaves half the M3 roles on Flutter
  defaults.

`verdant_ui` (unrelated product) formalizes exactly this: primitive →
semantic → component tokens, "no widget reads a raw color or number."

### The tension

Ground rule 4 says "no design system, no visual identity opinion … zero
shipped custom components." Read literally that means ship nothing. But a
spacing *scale* and a status-token *shape* aren't an identity — they're
the mechanism that makes consistency structural instead of a per-screen
judgment call. The current `app_theme_extension.dart` already ships one
example `ThemeExtension`; this proposal is to make that example a
genuinely useful empty scaffold rather than a throwaway.

### Proposed change

Replace the single placeholder `AppThemeExtension` with:

1. `AppSpacing` `ThemeExtension` — a fixed scale (`xs`…`xxxl`),
   `context.spacing` accessor, `lerp` implemented, `.standard()` fallback
   so a bare `ThemeData()` in a widget test still resolves it. No color,
   no opinion — just the scale.
2. `app_color_scheme.dart` switched to `ColorScheme.fromSeed(seedColor:
   <placeholder>, brightness: …)` with a comment: "derive the whole
   scheme from one seed; don't hand-assign a partial ColorScheme."
3. Keep the "replace freely" framing. Nothing here is a brand.

Leave status-color tokens as a documented pattern in the conventions
skill, not shipped code — they're more domain-shaped than spacing.

Update `CLAUDE.md` ground rule 4 to distinguish "no shipped visual
identity / no component library" (keep) from "no constraint scaffold"
(drop) — the spacing scale is explicitly allowed, empty of values that
imply a look.

## B10 — a PWA checklist (doc, or an opt-in `web_pwa` brick)

**APPLIED 2026-09-09** as `bricks/core_init/__brick__/docs/PWA-CHECKLIST.md`,
linked from QUICKSTART's "Further reading". Includes the CSP `<meta>` tag,
the random-UUID-not-fingerprint rule, and the retention-cap note added
since this proposal was written (`siap_jalan` ADR-0013/0015). The
optional `bricks/web_pwa` that patches `index.html` / `main.dart`
automatically is not done — still a doc the developer applies by hand.

`siap_jalan` ADR-0014 is the most complete Flutter-Web/PWA shipping
checklist across all projects. None of it is in the kit. At minimum add
`docs/PWA-CHECKLIST.md` to the generated project; optionally a
`bricks/web_pwa` that patches `web/index.html` and `main.dart`.

Checklist contents:

- `web/index.html`: a real `<meta name="viewport">` must exist (without
  it a phone renders at ~980px), plus `viewport-fit=cover` for notch
  insets.
- `MaterialApp.builder`: `MediaQuery.withClampedTextScaling(maxScaleFactor:
  1.3)` — fixed-height CTAs clip at OS 2x text size.
- One forced `ScrollBehavior` (`BouncingScrollPhysics` everywhere) so iOS
  Safari and Android Chrome don't scroll differently.
- A back control that always routes somewhere — an installed iOS PWA has
  no browser chrome and no back gesture.
- A production-only device-support gate built on a pure `evaluateDevice`
  function (unit-testable without a browser).
- Every route that reads `GoRouterState.extra` (or a path/query param
  reachable from stale history) gets a route-level `redirect` validating
  the shape before `builder` runs — `extra` is memory-only and a web
  reload is normal PWA use. See B5 below.

## B5 — `requireExtra<T>()` router helper (small, ship in core_init)

**APPLIED 2026-09-09.** `String? requireExtra<T>(GoRouterState state,
{required String fallback})` added to `lib/app/router.dart` with a
worked doc-comment example. New `test/app/router_helpers_test.dart` (3
cases: right type → null, null → fallback, wrong type → fallback). The
routing section of the conventions skill and `docs/PWA-CHECKLIST.md` both
name it now.

Add to `app/router.dart` a helper that returns a redirect string when
`state.extra` isn't the expected type, so route builders never
force-unwrap `extra!` (which crashes uncaught inside `build`, where
`errorBuilder` can't reach it). Ship it with a commented example on the
`example_feature` route. Low risk, pure addition — could fold this into
core_init directly rather than a proposal, pending the `mason make` test
run.

## B11 — migration playbook doc

**APPLIED 2026-09-09** as `bricks/core_init/__brick__/docs/MIGRATION-PLAYBOOK.md`,
linked from QUICKSTART. Covers the mechanical port plus the three
recurring ADRs, with the network-adaptation notes (absolute
`API_BASE_URL`, `MessageFailure` carve-out, device-metadata provider)
folded in.

Add `docs/MIGRATION-PLAYBOOK.md` (sibling to the future
`upgrade_to_monorepo` brick's ADR). The three migrations onto this kit
each produced the same three ADRs without coordinating:

1. "real visual identity replaces the placeholder" — delete the
   placeholder theme, don't layer.
2. "what the migration deliberately left out" — every skipped feature,
   dead widget, stale permission, with a reason.
3. "post-migration codebase-wide audit fixes" — run after the first
   post-migration feature lands, not right after the mechanical port.

Make these a required checklist, not a pattern each migration rediscovers.
Vault: `010 - Migration Playbook - The Three Recurring ADRs.md`.
