# Flutter Web / PWA checklist

This kit runs on web out of the box, but a Flutter app that only ever
ran on a phone makes assumptions that break in a browser tab. This list
is what `siap_jalan` (a rest-area PWA opened from a QR code) had to fix.
Work through it before shipping a web target; skip it entirely for a
mobile-only app.

## `web/index.html`

- **A real `<meta name="viewport">` must be present.** Without it a phone
  browser renders the app at ~980px and zooms out. An earlier edit to
  `index.html` dropped it once and nobody noticed until a real phone.
- **`viewport-fit=cover`** on that same meta tag, so Flutter's
  `SafeArea` can see the iOS notch and home-indicator insets.
- **`apple-mobile-web-app-status-bar-style`** = `black-translucent` if
  you want a coloured header to flow under the status bar like a native
  app. Needs a check on a real notched device — if the header overlaps
  the clock, use `black`.
- **A `Content-Security-Policy` `<meta>` tag.** `siap_jalan` ships
  `script-src 'self' 'wasm-unsafe-eval' www.gstatic.com` plus a bounded
  `connect-src` / `img-src`, so an injected script cannot pull remote
  code or exfiltrate local storage. `frame-ancestors` and
  `X-Content-Type-Options` cannot be set from `<meta>` — those, plus
  `X-Frame-Options: DENY`, belong in the web server / CDN response
  headers.

## `main.dart` / `MaterialApp`

- **Clamp text scaling.** Wrap the app in
  `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)` via
  `MaterialApp.builder`. Fixed-height CTAs, pills, and gauges clip at an
  OS text size of 2x (iOS "Larger Text", Android "Largest"). 1.3x still
  honours a real preference for bigger text.
- **One forced `ScrollBehavior`.** Flutter Web picks scroll physics from
  the detected platform, so the same PWA rubber-bands on iOS Safari and
  clamps in Android Chrome. A single `ScrollBehavior` that forces
  `BouncingScrollPhysics` everywhere (and drops the desktop scrollbar)
  makes the scroll feel consistent.
- **One Material look on both engines.** No Cupertino widgets, no
  `.adaptive` constructors, no `Theme.of(context).platform` branching —
  the app renders in both WebKit and Blink and should look the same in
  both. Bundle fonts rather than relying on system fonts for the same
  reason.

## Routing

- **Every route that reads `GoRouterState.extra` needs a route-level
  `redirect` validating the shape before `builder` runs.** The kit ships
  `requireExtra<T>(state, fallback: '/...')` in `app/router.dart` for
  exactly this.
  `state.extra` is in-memory only and does not survive a full page
  reload — and on a PWA, reloading or resuming a backgrounded tab is
  normal use, not an edge case. A `builder` that does `extra!` crashes
  uncaught inside `build`, where `errorBuilder` cannot reach it. Same
  applies to path/query params reachable from a stale bookmark or
  browser back/forward. The safe fallback is a redirect home.
- **The back control must always route somewhere.** An installed iOS PWA
  has no browser chrome and no back gesture — the only way off a screen
  is the control you draw. An app-bar back button that pops when it can
  and otherwise goes to the home route covers it. The root route can use
  a double-press-to-exit `PopScope` (the Android idiom; inert on iOS
  standalone).

## Device coverage

- **Production-only device-support gate.** If the app is only meant for
  phones/tablets, redirect anything else to a styled "not supported"
  page in production (leave it off in dev/staging so a desktop browser
  stays usable for development). Build the classification as a pure
  function — on web it reads `navigator.userAgent`, `maxTouchPoints`
  (the iPadOS-13-as-desktop tell), and the screen's shorter edge — so it
  is unit-testable without a browser.
- **The web device id is a random UUID, not a browser fingerprint.**
  `siap_jalan` ADR-0015: an id built by hashing browser signals
  (user-agent, canvas render, WebGL strings, audio `sampleRate`)
  produced *the same id* for two different Windows laptops. The signals
  that would distinguish machines carry no entropy after browser privacy
  reductions; the stable ones are shared by whole populations. If you
  need a per-install id, mint `Uuid().v4()` once and cache it in
  storage. A real per-person id needs a user-entered anchor and backend
  dedup.
- **Tablet layout.** The cheap option that does not break: cap content
  width (~480px), centre it, tint the surround. The margins then read as
  a deliberate panel rather than a stretched phone layout. `manifest.json`
  can keep `orientation: portrait-primary` — Android Chrome honours it,
  iOS Safari ignores it, and as long as every screen is a scroll view a
  short wide viewport just scrolls.

## Local storage on web

- **Moving to `hive_ce` moved the auth token from an OS keystore into
  unencrypted IndexedDB**, readable by any script on the origin. Whether
  that matters depends on what the token grants — a throwaway
  session credential with no user account behind it is low-stakes; a
  token tied to real identity or history is not. The CSP above is the
  main mitigation; `flutter_secure_storage` on mobile or an `HttpOnly`
  cookie on web is the bigger fix if the threat model needs it.
- **Cap any unbounded local list of user data.** A growing
  `result_history` / draft list is a growing plaintext footprint.
  `siap_jalan` keeps only the 20 most recent results and drops older
  ones on each write. Client-side encryption does not help against the
  real threat (XSS holds the key too) — a retention cap and a CSP do.
