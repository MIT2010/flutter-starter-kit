# Migration playbook

For moving an existing production Flutter app onto this starter kit's
structure. Three real apps have done it (`etle_mobile`,
`visitasi_sekolah_mengemudi`, `siap_jalan`). Each one produced the same
three follow-up ADRs without coordinating — so they are written down here
as a checklist instead of being rediscovered every time.

This doc is about the *process*. The structural rules themselves
(`data/domain/presentation`, `Result<Failure, S>`, one Dio, one router)
live in the ADRs under `decisions/` and in `CLAUDE.md`.

## The mechanical port

1. **Map the folders.** `lib/src/{core,features}` (or whatever the legacy
   layout was) becomes `lib/{app,core,features}`. Every feature gets all
   three layers even if the legacy app had a flat one.
2. **Drop the usecase layer if there is one.** This kit's convention is
   cubit → repository directly. Fold each usecase's body into the
   repository method or the cubit. `siap_jalan` ADR-0012 did this
   deliberately — it is a reduction, not an oversight.
3. **`dartz` `Either` → `Result<Failure, S>`.** Not a mechanical rename:
   `Left`/`Right` become `ResultFailure`/`Success`, and every `.fold`
   call site changes shape. Repository methods that returned a nullable
   or threw now return `Result`.
4. **Collapse model/entity duplication.** A legacy `FooModel extends
   FooEntity` that adds nothing becomes a single `@freezed` `Foo` in
   `data/models/`, referenced straight from the domain interface. Keep
   the split only where the data class genuinely transforms into
   something else.
5. **Delete `example_feature`.** It is this kit's demo scaffold, not part
   of the product. Point `/` at the real home screen.
6. **Auth wiring.** The legacy token mechanism rarely matches the kit's
   `AuthInterceptor` + `SessionExpiryInterceptor` default. Check what the
   backend actually does on an expired session (a 401? a 200 with an
   error body? no signal at all?) before assuming either interceptor
   fits — see ADR-0012 and the network-adaptation notes below.

Run `flutter analyze` and `flutter test` clean before moving on. The
mechanical port is not the interesting part; the three ADRs below are.

## ADR 1 — real visual identity replaces the placeholder

Delete `lib/app/theme/`'s placeholder `ThemeExtension` and `ColorScheme`
outright. Do not layer the real theme on top of a placeholder nobody
will ever select — that is just dead code with a confusing name.

Both visual-redesign passes that have happened on this kit
(`etle_mobile` ADR-0019/0023, `visitasi` ADR-0019) converged on the same
shape independently:

- `ColorScheme.fromSeed(...)`, never a hand-assigned partial
  `ColorScheme` that leaves half the M3 roles on Flutter defaults.
- A spacing scale as a `ThemeExtension` (`context.spacing`), replacing ad
  hoc `EdgeInsets` / `SizedBox` numbers.
- Status/semantic colours as tokens: one colour + icon + label per
  lifecycle state, resolved from an unstructured backend string by
  keyword match with an explicit `unknown` fallback. Never exact-match.
- Contrast measured against the actual surface, not eyeballed. Both
  passes found a pre-existing WCAG failure only because every role was
  being re-derived from scratch.
- If the app is dark-only (or light-only), delete the other branch.
  Keeping an unused one just lets it drift.

Write this up as an ADR so the next person does not treat the deleted
placeholder as a regression.

## ADR 2 — what the migration deliberately left out

Grep the legacy `lib/` for call sites before carrying anything over.
Anything with zero references outside its own definition file is dead
code — relocating it just moves the dead code. List every exclusion with
a reason:

- Unused shared widgets (`etle` ADR-0017 dropped `ResponsiveBuilder`,
  `DropdownInputField`, a `ToastSuccess`; `visitasi` ADR-0015 dropped
  `ResponsiveLayout`, `StackedList`).
- Features that never actually shipped (a history tab backed by
  hardcoded mock data; a camera flow importing a package that was never
  in `pubspec.yaml`).
- Stale Android permissions. `ACCESS_BACKGROUND_LOCATION` declared with
  no background-location code path triggers Google Play policy review
  for nothing.
- Deployment infra (`Dockerfile`, `Jenkinsfile`) — port it later if
  asked, it is not part of the architecture migration.
- Private keys / local TLS certs sitting in the legacy repo root. Do not
  copy them into the new repo.

The point of the list is that a later change should not "restore" one of
these blind, not knowing it was removed on purpose.

## ADR 3 — post-migration codebase-wide audit

Run this *after* the first real feature lands on top of the migrated
code, not right after the mechanical port. The port itself is
low-surprise; the bugs surface once new code exercises the seams.

`visitasi` ADR-0018 ran six independent reviewers (one per module area),
each finding confirmed by a second adversarial pass — 26 findings
survived. Recurring shapes worth looking for specifically:

- `emit()` after an `await` with no `if (isClosed) return;` guard —
  throws, does not no-op.
- Route builders that force-unwrap `GoRouterState.extra` — crashes
  uncaught on a web reload. See PWA-CHECKLIST.md.
- App-lifetime singletons caching user data with no reset on logout —
  see security pattern #6.
- A silent `catch (_)` that discards an exception with no log — see
  ADR-0011 (app-flow logging).
- Two components both clearing the same persisted key, neither owning it.

## Network-layer adaptations (the common ones)

- **The kit's `RefreshTokenInterceptor` default rarely fits.** None of
  the three migrations had a `/auth/refresh` endpoint. The kit ships
  `SessionExpiryInterceptor` as the default now (ADR-0012); confirm even
  that matches your backend's real expiry signal before trusting it.
- **`API_BASE_URL` must be an absolute URL.** `Dio(BaseOptions(baseUrl:
  '/api'))` throws `Invalid argument (baseUrl): Must be a valid URL on
  platforms other than Web` on every non-web platform. A legacy app that
  used a bare `/api` default was relying on a deploy-time override. Set
  each `config/*.json`'s `API_BASE_URL` to a bare `http(s)://host:port`
  and keep any `/api/...` prefix on the per-endpoint paths.
- **A backend `msg` / `message` field is sometimes written to be shown
  to the user.** If the backend author confirms it (as in `etle` and
  `siap_jalan`), pass it through a `MessageFailure` — the one vetted
  exception to "no raw backend strings in the UI". Everything
  exception-shaped still maps to a generic `Failure` via `mapDioError`.
- **Consolidate per-call-site device/app metadata collection** into one
  injectable provider rather than repeating the same block in every
  cubit that hits the network.
