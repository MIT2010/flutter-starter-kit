# ADR-0013: A valueless spacing scale ships by default; the theme extension is no longer a throwaway

## Status

Accepted

## Context

The kit shipped `AppThemeExtension` — an example `ThemeExtension` with a
`successColor`, a `warningColor`, and a `spacingUnit`, all placeholder
values under a `.placeholder(brightness:)` factory. It existed only to
show the *shape* of a theme extension; nothing read it, and the comment
told you to delete it.

Every real app built on this kit deleted it and then rebuilt the same
thing. Two visual-redesign passes on downstream apps (`etle_mobile`
ADR-0019/0023, `visitasi_sekolah_mengemudi` ADR-0019), done months apart
without coordinating, each landed on an `AppSpacing` `ThemeExtension`
with a fixed step scale read via `context.spacing`, replacing ad hoc
`EdgeInsets` / `SizedBox` numbers. A spacing scale is not a visual
identity — it is the mechanism that makes spacing consistent instead of
a per-screen guess.

Ground rule 4 ("no design system, no visual identity opinion, zero
shipped custom components") read literally says ship nothing. It is now
worded to draw the line at *values that imply a look* — a palette, a
font, a component — not at a bare scale.

## Decision

- **`lib/app/theme/app_spacing.dart`** replaces `app_theme_extension.dart`.
  `AppSpacing extends ThemeExtension<AppSpacing>` with six steps
  (`xs` 4 … `xxl` 48), a `const AppSpacing.standard()`, `copyWith`, and
  `lerp`. No colour, no font, nothing brightness-dependent.
- **`context.spacing`** (an extension on `BuildContext`) is the read
  path. It falls back to `AppSpacing.standard()` when the ambient theme
  carries no `AppSpacing`, so a bare `MaterialApp()` in a widget test
  works without building a full app theme — this is why the widget/golden
  tests that pump `const MaterialApp(home: ...)` still pass.
- `buildAppTheme` registers `const [AppSpacing.standard()]`.
  `example_feature_page.dart` and the `feature` brick's page template
  read `context.spacing.md` / `.sm` instead of literals — same pixel
  values as before, so the golden is unchanged.
- **`app_color_scheme.dart` is unchanged in behaviour** — it already used
  `ColorScheme.fromSeed`. Its doc comment now says explicitly: derive the
  whole scheme from one seed, never hand-assign a partial `ColorScheme`
  (that leaves half the M3 roles on Flutter defaults).
- **Status/semantic colour tokens are NOT shipped.** They are more
  domain-shaped than spacing (which lifecycle states an app has is an app
  decision). The shape to copy — one colour + icon + label per state,
  resolved from an unstructured backend string by keyword match with an
  explicit `unknown` fallback — is documented in the
  `flutter-starter-kit-conventions` skill, not in code here.

## Alternatives considered

- **Keep the throwaway `AppThemeExtension`**: rejected — three apps
  proved it is rework waiting to happen, and a placeholder nobody keeps
  teaches nothing a one-paragraph doc couldn't.
- **Ship colour tokens too** (a `successColor` etc. as real theme
  tokens): rejected — that is the palette opinion ground rule 4 exists to
  avoid. Spacing is defensible as valueless; a set of named semantic
  colours is not.
- **A full primitive → semantic → component token system** (as in
  `verdant_ui`): rejected as a default — correct for a design-system
  product, far past what a starter kit's Layer 0 should impose.

## Consequences

- Ground rule 4 in the starter kit's `CLAUDE.md` now permits this one
  valueless scale explicitly. A contributor adding colour, typography, or
  a component to `lib/app/theme/` is still outside the rule.
- A new widget should read `context.spacing.*`, not a bare number. A
  private helper with no `BuildContext` takes an `AppSpacing` parameter.
- Changing the scale (different steps, more steps) is a one-file edit
  with `lerp`/`copyWith`/tests alongside it.
