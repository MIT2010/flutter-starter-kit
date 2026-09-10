# Architecture

This document explains how a project generated from the starter kit is
put together: the ideas behind it, what each folder is for, how the parts
talk to each other, and how to decide where a new piece of code belongs.

Read `docs/QUICKSTART.md` first if you just want to run the app. Read the
ADRs under `docs/decisions/` if you want the full reasoning behind a
specific choice. This document is the map that sits between those two.

---

## The short version

- **One architecture for every project, revealed in layers.** You start
  with a single-package layout (Layers 0–3). The multi-package split
  (Layer 4) exists but stays off until a migration brick turns it on.
- **`lib/` has exactly three top-level areas.** `app/` wires everything
  together, `core/` holds shared infrastructure, `features/` holds the
  product. Dependencies point one way: `features → core`, and only
  `app/` is allowed to know about everything.
- **Every feature has the same three layers** — `data`, `domain`,
  `presentation` — with no "this one is too small for that" exception.
- **A generator writes the boilerplate.** `mason make feature` creates
  the folders, the DI registration, and the route entry. You fill in the
  logic.
- **Failures are return values.** Repository methods hand back
  `Result<Failure, S>`. Exceptions never travel up into a cubit or a
  widget.
- **A few known production bugs are designed out**, not left to code
  review — see "Security and correctness, built in" below.

---

## Philosophy

### Progressive disclosure

Most Flutter architecture debates are really about scale. A monorepo with
six packages is right for a team shipping four apps off a shared core. It
is dead weight for a single app three weeks into its life.

So the kit picks a default and defers the rest:

| Layer | What it adds | On by default? |
|---|---|---|
| 0 | `lib/{app,core,features}`, one package | yes |
| 1 | `Result`/`Failure`, the shared Dio client, Hive storage | yes |
| 2 | Cubit state, injectable DI, go_router with a real guard | yes |
| 3 | the `feature` generator, golden tests, CI | yes |
| 4 | Melos / multi-package split (`packages/`, `apps/`) | **no** — opt-in via a separate migration brick |

You never decide "which architecture" at the start of a project. You get
Layers 0–3, and if you later have two real apps sharing code, you run the
migration for Layer 4. Until then, the absence of `melos.yaml` is the
signal that you are single-package, and nothing should assume otherwise.

### Feature-first, with a fixed internal shape

Code is grouped by **what it does for the user** (`features/auth`,
`features/checkout`), not by technical role (`models/`, `repositories/`,
`widgets/` at the top level). When you work on a screen, everything for
that screen is in one folder.

Inside every feature, the shape is always the same:

```
features/<name>/
├── data/            # talks to the outside world
│   ├── models/          # DTOs — freezed classes with fromJson
│   └── repositories/    # the concrete implementation
├── domain/          # the feature's contract
│   └── repositories/    # abstract interface the presentation layer depends on
└── presentation/    # what the user sees
    ├── cubit/           # one cubit + one sealed state class
    └── pages/           # the routed screen(s)
```

There is no flattened variant for "simple" features. A single-field
settings toggle gets `data/domain/presentation` too. This looks like
overkill for the small case, and it is — on that one feature. Across a
codebase with thirty features and five contributors, "is this feature
simple enough to skip a layer" is a question each person answers
differently, and the result is thirty features in a dozen slightly
different shapes. One shape, always, is worth the occasional near-empty
folder. See ADR in `docs/decisions/` and the reasoning in
`CLAUDE.md` ground rule 2 of the kit repo.

### Ceremony belongs in a generator

Adding a feature by hand means creating six or seven files, registering a
repository and a cubit with the DI container, and adding a route. Every
one of those is a place to make a copy-paste mistake, and none of them is
interesting work.

`mason make feature --feature_name <name> --project_name <pkg>` does all
of it in one pass: the three layers, the `@injectable` annotations, a
`GoRoute` entry wired into `lib/app/router.dart`, and test skeletons.
`lib/app/router.dart` carries two marker comments
(`feature_brick:import_marker`, `feature_brick:route_marker`) that a
post-generation hook edits — that is how the route gets added without you
touching the file.

The rule that follows: if you find yourself hand-typing the same
structure a generator could produce, stop and use the generator. If the
generator genuinely cannot express what you need, that is a real finding
worth an ADR, not a reason to improvise silently.

### Errors are values, not exceptions

A repository method that can fail returns `Result<Failure, S>` — a sealed
type with exactly two shapes, `Success<F, S>` and `ResultFailure<F, S>`.
It never throws to its caller, and it never returns `null` to mean "it
didn't work".

```dart
Future<Result<Failure, User>> getUser(String id) async {
  try {
    final res = await _dio.get<Map<String, dynamic>>('/users/$id');
    return Result.success(User.fromJson(res.data!));
  } on DioException catch (e) {
    return Result.failure(mapDioError(e));   // network/HTTP failure → generic Failure
  } catch (e, stackTrace) {
    // logs the detail, returns a generic Failure — see core/logging/unexpected_error.dart
    return unexpectedError(_logger, 'getUser', e, stackTrace);
  }
}
```

The cubit then pattern-matches and cannot forget the failure case,
because the type has no third option:

```dart
final result = await _repository.getUser(id);
if (isClosed) return;
emit(result.fold(
  onFailure: ProfileState.error,
  onSuccess: ProfileState.loaded,
));
```

`Failure` (`lib/core/failure.dart`) is a small fixed set of user-safe
types — `NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`,
`UnknownFailure`, `CacheFailure` — each carrying a hardcoded message that
is safe to put on screen. A raw backend error string never becomes a
`Failure` message. The one deliberate exception is `MessageFailure`, for
the case where a backend's `message` field is confirmed to be
display-authored copy; its doc comment spells out exactly what may and
may not go into it.

### Security and correctness, built in

A handful of Flutter production bugs recur often enough that the kit
structures them out rather than trusting a reviewer to catch them:

- **Every Dio interceptor is attached.** `lib/core/network/dio_client.dart`
  builds one list, and a test asserts all three expected interceptor
  types are on the client. An interceptor that is written but never
  attached — a real bug that has shipped, with every request silently
  going out unauthenticated — fails the test instead.
- **Logging redacts before it prints.** `LoggingInterceptor` runs request
  and response bodies through a redaction list; it never logs a raw body.
  App-flow logging (`AppBlocObserver`, `AppNavigatorObserver`) logs type
  names and route names only, never a state object's fields, because a
  `freezed` `toString()` will happily print a token.
- **The 401 handler excludes the login endpoint.** A failed login
  legitimately returns 401. The default `SessionExpiryInterceptor`
  (and the opt-in `RefreshTokenInterceptor`) skip `/auth/login`, so a
  wrong password can't bounce the user off the screen they're on or
  trigger a refresh loop.
- **Temp files have a cleanup path.** `lib/core/storage/temp_file_cleanup.dart`
  exists so that any code writing to temp storage has a discoverable,
  testable way to delete it again.
- **The router tells "not checked yet" apart from "logged out."** See
  "The router guard" below.

---

## Why this and not something else

- **Why not Riverpod for state?** Cubit + `flutter_bloc` is the default
  because its state transitions are explicit and easy to test, and the
  kit already uses `get_it`/`injectable` for DI. Mixing Riverpod
  providers with `get_it` means two overlapping DI-shaped systems for no
  clear gain at this size. Nothing stops a project adopting Riverpod
  later; it just isn't the baseline.
- **Why the `domain/` layer if the model and the entity are identical?**
  The value is the *interface*. `presentation/` depends on
  `domain/repositories/<feature>_repository.dart` (abstract), never on
  the `Impl`. That is what lets a cubit test run against a mock with no
  Dio and no Hive. The kit does not keep a separate `Entity` class when
  it would be a byte-for-byte copy of the model — one `freezed` model,
  referenced from the domain interface, is enough.
- **Why single-package by default?** A multi-package split has a real,
  ongoing cost — `melos bootstrap`, versioning, inter-package
  boundaries — that only pays off when more than one app shares the code.
  Adding it later is a mechanical migration. Removing it once it's woven
  in is not.
- **Why `--dart-define-from-file` for config instead of a `.env` file?**
  `.env` files are read at runtime from a bundled asset, so their values
  ship inside the app and can be extracted. `String.fromEnvironment`
  bakes values in at compile time. See ADR-0009.

---

## The folder map

```
lib/
├── main.dart                 # entry point — see "Startup sequence"
├── app/                      # composition root: wires core + features together
│   ├── di.dart               # get_it entry point (configureDependencies)
│   ├── di.config.dart        # GENERATED by injectable — never hand-edit
│   ├── router.dart           # the one GoRouter, its guard, requireExtra<T>()
│   ├── auth_status_notifier.dart   # app-wide "is the user logged in" signal
│   ├── widgets/
│   │   └── confirm_dialog.dart     # confirmDialog() → Future<bool>, dismiss = false
│   └── theme/
│       ├── app_theme.dart          # buildAppTheme(brightness:)
│       ├── app_color_scheme.dart   # placeholder ColorScheme.fromSeed — replace freely
│       └── app_spacing.dart        # AppSpacing scale, read as context.spacing.md
├── core/                     # shared infrastructure, no feature knowledge
│   ├── result.dart           # Result<F, S>
│   ├── failure.dart          # Failure hierarchy + MessageFailure
│   ├── config/
│   │   └── app_config.dart   # compile-time env values (flavor, API URL, flags)
│   ├── network/
│   │   ├── dio_client.dart           # the one shared Dio, all interceptors attached
│   │   ├── dio_error_mapper.dart     # DioException → Failure
│   │   └── interceptors/             # auth, logging (redacted), session-expiry, refresh
│   ├── storage/
│   │   ├── hive_client.dart          # the only class that touches Hive directly
│   │   └── temp_file_cleanup.dart    # discoverable temp-file deletion
│   └── logging/
│       ├── app_logger.dart           # shared Logger instance (DI)
│       ├── unexpected_error.dart     # unexpectedError(): log + generic Failure for a catch branch
│       ├── app_bloc_observer.dart    # logs every cubit's lifecycle
│       └── app_navigator_observer.dart  # logs every navigation
└── features/
    ├── auth/                 # real login/logout, locally simulated by default
    └── example_feature/      # reference slice: one real network read
```

A few more directories appear once a project needs them. None ship in a
fresh generation:

- **`lib/core/services/`** — a cross-feature capability that has no screen
  (geolocation, a printer, a share sheet, a web-download helper). One
  `@lazySingleton`, returns `Result<Failure, S>` like a repository.
- **`lib/core/device/`** — anything that reads device or platform
  identity: a device-id provider, a device-metadata collector, a
  platform-support classifier. Injectable, no screen — the same category
  as `services/`. Two downstream apps built this folder independently.
- **`lib/core/models/`** — a value type two or more features share (a
  `Money`, a `GeoPosition`). A type used by one feature stays in that
  feature's `data/models/`.
- **`lib/app/pages/`** — a static screen with no data layer (a consent
  gate, an "unsupported device" notice).
- **`lib/app/widgets/`** — UI shared by more than one feature. Ships with
  `confirm_dialog.dart` (a styleless `confirmDialog() → Future<bool>`);
  see "The shared-widget set you will build" below.
- **`lib/app/assets.dart`** (or `core/constants/`) — typed asset paths, so
  widgets reference `Assets.logo` instead of a bare `'assets/…'` string.

More on these under "Where does this code go?".

---

## `lib/app` — the composition root

`app/` is the only place allowed to import from both `core/` and
`features/`. It knows the whole graph; nothing in the graph knows it
back (with one small, deliberate exception noted below).

**`di.dart`** exposes `getIt` and `configureDependencies()`. The actual
registrations live in `di.config.dart`, generated by `injectable` from
the `@injectable` / `@lazySingleton` / `@module` annotations scattered
across the codebase. You run `dart run build_runner build` after adding
an annotated class; you never edit `di.config.dart`.

**`router.dart`** holds the single `GoRouter`. New routes are one more
`GoRoute` in the existing list — never a second router. It also ships
`requireExtra<T>(state, fallback: '/...')`: a guard for any route that
reads `GoRouterState.extra`, so a `builder` never force-unwraps `extra!`
and crashes on a web reload or a deep link. See `docs/PWA-CHECKLIST.md`.

### The router guard

The redirect callback distinguishes three states, not two:

```dart
if (authStatus == AuthStatus.unknown)        return null;      // check not done — do NOT redirect
if (authStatus == AuthStatus.unauthenticated && !goingToLogin) return '/login';
if (authStatus == AuthStatus.authenticated  &&  goingToLogin)  return '/';
return null;
```

The bug this avoids: treating "auth status not resolved yet" the same as
"resolved to logged out". A naive guard bounces an already-logged-in user
to `/login` on every cold start, for the split second before the stored
token is read. `main.dart` starts that read **without awaiting it**, so
the `unknown` window is real and the guard has to handle it. See
ADR-0003.

**`auth_status_notifier.dart`** is app-level plumbing, not a feature. It
is a `ChangeNotifier` with three states (`unknown` / `authenticated` /
`unauthenticated`), backed by `HiveClient`. The router listens to it via
`refreshListenable`, so calling `markAuthenticated()` re-runs the
redirect. It holds *status only* — the real login logic is in
`features/auth`, and `AuthCubit` calls `markAuthenticated()` /
`markUnauthenticated()` once its repository call actually succeeds.

**`theme/`** is a scaffold with no visual identity. `app_color_scheme.dart`
is a placeholder `ColorScheme.fromSeed` you are expected to replace.
`app_spacing.dart` is the one real token: a valueless step scale
(`xs` 4 … `xxl` 48) read as `context.spacing.md`, with a `.standard()`
fallback so a bare `MaterialApp` in a widget test resolves it. See
ADR-0013.

### The rule for `app/`

Put something in `app/` only if it is **wiring or an app-wide signal**:
the router, the DI entry point, the theme, a `ChangeNotifier` the router
depends on. If it has business logic, a screen, or talks to the network,
it does not belong here.

---

## `lib/core` — shared infrastructure

`core/` is code that more than one feature needs and that has **no
knowledge of any feature**. It never imports from `features/`. If you
find a `core/` file importing `features/…`, that is a design error to fix,
not a shortcut to keep.

What lives here:

| Area | What it is |
|---|---|
| `result.dart`, `failure.dart` | the error-handling vocabulary the whole app speaks |
| `config/app_config.dart` | compile-time env values — API base URL, flavor, logging flags |
| `network/` | the single shared `Dio`, its interceptors, and `DioException → Failure` mapping |
| `storage/` | `HiveClient` (the only direct Hive caller) and temp-file cleanup |
| `logging/` | one shared `Logger`, plus the bloc and navigator observers |

There is exactly **one** Dio instance and **one** Hive box, both provided
by `@module` classes and injected everywhere they are needed. A feature
that needs the network takes `Dio` in its repository constructor. It does
not build its own client or add its own interceptor.

`core/network/interceptors/` ships four interceptors. Three are attached
by default (`AuthInterceptor`, `LoggingInterceptor`,
`SessionExpiryInterceptor`); `RefreshTokenInterceptor` sits alongside,
unattached, as a one-file swap for backends that issue refresh tokens
(ADR-0012).

### The one allowed `core → app` reference

`session_expiry_interceptor.dart` imports
`app/auth_status_notifier.dart`. This is a deliberate exception:
`AuthStatusNotifier` is the app-wide session signal the router already
depends on, it holds no network logic, and it does not import back into
`core/network/`, so there is no cycle. The alternative — a bespoke
callback abstraction — would add a layer for no real benefit. Every real
migration onto this kit wired the interceptor straight to the notifier
anyway.

### The rule for `core/`

Put something in `core/` if it is **infrastructure used by two or more
features and free of feature-specific meaning**. The moment it needs to
know what "an order" or "a lesson" is, it belongs in a feature instead.

---

## `lib/features` — the product

Everything a user actually does. Each feature is self-contained: its own
data, domain, and presentation, importing from `core/` and from nothing
else under `features/`.

The kit ships two:

- **`auth/`** — a real, fully-layered login/logout feature. By default it
  simulates login locally (any valid email + a 6-character password
  succeeds) because there is no public auth backend worth depending on
  out of the box. Wiring a real backend means replacing the body of
  `AuthRepositoryImpl` and nothing else. See ADR-0007.
- **`example_feature/`** — the reference slice. One real network read
  (`GET /posts/1` against a placeholder API), showing the full path from
  screen to cubit to repository to Dio and back as a `Result`. Read its
  six files before writing your first feature; delete it once you don't
  need the reference.

### One slice, walked through

`example_feature` in dependency order:

1. **`data/models/example_item_model.dart`** — a `freezed` class with a
   `fromJson`. This is the shape of the API response, nothing more.
2. **`domain/repositories/example_feature_repository.dart`** — the
   abstract interface:
   `Future<Result<Failure, ExampleItem>> getExampleItem()`. The
   presentation layer depends on *this*.
3. **`data/repositories/example_feature_repository_impl.dart`** —
   `@LazySingleton(as: ExampleFeatureRepository)`. Takes `Dio` and
   `Logger` by constructor injection. Calls the API, maps a
   `DioException` through `mapDioError`, logs and swallows anything
   unexpected, and always returns a `Result`.
4. **`presentation/cubit/example_feature_state.dart`** — a `freezed`
   sealed state: `initial` / `loading` / `loaded(item)` / `error(failure)`.
5. **`presentation/cubit/example_feature_cubit.dart`** — `@injectable`.
   Emits `loading`, awaits the repository, guards with `if (isClosed)
   return;` after the await, then `fold`s the `Result` into `loaded` or
   `error`.
6. **`presentation/pages/example_feature_page.dart`** — a
   `BlocProvider` + `BlocBuilder` that `switch`es on the sealed state.
   Reads spacing via `context.spacing`.

### The rules for a feature

- `presentation/` depends on `domain/` (the interface), never on
  `data/repositories/…Impl` directly.
- `data/` implements `domain/`. It is the only layer that imports Dio,
  Hive, or another package's SDK.
- One cubit per feature, emitting one sealed state class. A second cubit
  is justified only when the feature has a genuinely separate lifecycle —
  e.g. a full-screen submit/result flow the user can't back out of.
  Prefer a plain `StatefulWidget` for pure animation; not everything
  stateful needs a cubit.
- A feature never imports another feature. If two features need the same
  thing, that thing moves to `core/` (if it's infrastructure) or
  `core/models/` (if it's a shared value type).
- After any real `await` in a cubit method, guard the next `emit()` with
  `if (isClosed) return;`. `emit()` after `close()` throws.

---

## How the parts talk to each other

### Dependency direction

```
        ┌─────────────────────────────────────────┐
        │                  app/                    │
        │   router · di · theme · auth_status      │
        └───────────────┬───────────────┬─────────┘
                        │ imports       │ imports
                        ▼               ▼
        ┌───────────────────┐   ┌───────────────────────────┐
        │      features/    │   │           core/           │
        │  auth · example   │──▶│  result · failure · dio   │
        │                   │   │  hive · logging · config  │
        └───────────────────┘   └───────────────────────────┘
                        (features import core, never the reverse,
                         and never another feature)
```

Only `app/` reaches into both sides. `features/ → core/` is the only
cross-boundary import a feature makes. `core/ → app/` happens exactly
once, on purpose (the session-expiry interceptor, explained above).

### A request, end to end

```
LoginPage
  └─ context.read<AuthCubit>().login(email, password)
       └─ AuthCubit  emits AuthState.loading
            └─ AuthRepository.login(...)            ← domain interface
                 └─ AuthRepositoryImpl              ← data impl (injected)
                      └─ (real backend) Dio.post('/auth/login')
                           └─ AuthInterceptor adds the bearer token
                           └─ LoggingInterceptor logs it, redacted
                      └─ returns Result<Failure, AuthUser>
            └─ AuthCubit.fold:
                 success → AuthStatusNotifier.markAuthenticated()
                           emit AuthState.success
                 failure → emit AuthState.error(failure)
  └─ AuthStatusNotifier notifies → GoRouter refreshListenable fires
       └─ redirect re-runs → authenticated + on /login → go to '/'
```

The screen never sees an exception. It sees state transitions and, on
failure, a `Failure` with a message it can show directly.

### Dependency injection

`injectable` scans annotations and generates `di.config.dart`:

- `@injectable` — a new instance every time it's resolved (cubits).
- `@lazySingleton` — one instance, built on first use (repositories,
  `HiveClient`, `AppLogger`).
- `@singleton` — one instance, built at startup (`AuthStatusNotifier`).
- `@module` — for third-party types you can't annotate (`Dio`, the Hive
  `Box`, `Logger`). `@preResolve` on the Hive `Box` means DI awaits it
  during `configureDependencies()`, so `HiveClient` can take an
  already-open box.

You add an annotation, run `build_runner`, and the class is available via
constructor injection or `getIt<T>()`. You do not write
`getIt.registerFactory(...)` by hand.

### Cross-cutting signals

Two things are genuinely app-wide and travel outside the normal
cubit→repository path:

- **`AuthStatusNotifier`** — the "is there a session" signal. Features
  push to it (`AuthCubit` on login/logout); the router and the
  session-expiry interceptor read from it. It is a `ChangeNotifier`, so
  the router's `refreshListenable` reacts automatically.
- **The shared `Logger`** — injected anywhere logging is needed, so the
  whole app has one printer configuration. `AppBlocObserver` and
  `AppNavigatorObserver` use it to trace cubit and navigation activity,
  gated by `AppConfig.enableAppFlowLogging`.

### Startup sequence (`main.dart`)

```dart
WidgetsFlutterBinding.ensureInitialized();
await configureDependencies();               // DI graph ready (Hive box awaited)
Bloc.observer = getIt<AppBlocObserver>();    // cubit lifecycle logging, app-wide
unawaited(getIt<AuthStatusNotifier>().resolve());  // NOT awaited — the `unknown` window is intentional
runApp(const MyApp());                       // renders immediately; router guard handles `unknown`
```

---

## Where does this code go?

The decision is almost always answerable with three questions, in order.

**1. Does a user navigate to a screen this owns?**
Yes → it's a **feature**. Generate it with `mason make feature`. Even if
it's small. Even if it's "just a form".

**2. Does it have business meaning — a concept from the product domain
(an order, a booking, a lesson, a role)?**
Yes, and it's used by one feature → it stays **inside that feature**
(usually `data/` or `domain/`).
Yes, and two or more features need the identical type → `lib/core/models/`.

**3. Is it infrastructure — networking, storage, logging, a platform
capability, a pure utility — with no feature meaning?**
Yes → **`core/`**.
Yes, but it's a capability with no screen that wraps a plugin
(geolocation, printing) → **`core/services/`**.

If none of those fit, it's probably **`app/`** — but only if it's wiring
(the router, DI, theme) or an app-wide signal the router or startup
depends on. `app/` is a small place. Most code that feels like it belongs
there actually belongs in a feature or in `core/`.

### Worked examples

| You're adding… | Where | Why |
|---|---|---|
| A "Notifications settings" screen | `features/notification_settings/` | it's a screen; full three layers, even though it's one toggle |
| The `Order` model, used only by checkout | `features/checkout/data/models/` | domain meaning, one feature |
| The `Money` value type, used by cart *and* checkout | `core/models/money.dart` | shared value type, no screen |
| A retry helper for flaky requests | `core/network/` | infrastructure, no feature meaning |
| A geolocation wrapper (`geolocator` + `geocoding`) | `core/services/geolocation_service.dart` | cross-feature capability, no screen; returns `Result<Failure, LocationFix>` |
| A device-id provider / a "device model + OS version" collector | `core/device/` | device identity is infrastructure, no screen |
| A `DateFormat` wrapper for showing timestamps | `core/date_format.dart` (add `intl` yourself) | a pure utility with no feature meaning |
| Constants for asset paths (`assets/logo.png`, …) | `app/assets.dart` | one typed place, so widgets never hold a bare `'assets/…'` string |
| A "You're offline" full-screen notice with no data | `app/pages/offline_page.dart` | a screen with nothing to layer — no cubit, no repository |
| `AppButton`, used by three features | `app/widgets/app_button.dart` | shared UI atom; a one-feature widget stays in that feature's `presentation/widgets/` |
| A `ChangeNotifier` the router must react to | `app/` | app-wide signal the router's `refreshListenable` depends on |
| A new Dio interceptor | `core/network/interceptors/` + attach it in `dio_client.dart` + update the count test | infrastructure; the test is what stops it shipping unattached |

### The shared-widget set you will build

The kit ships one shared widget — `app/widgets/confirm_dialog.dart`, a
styleless `confirmDialog() → Future<bool>` where any dismissal means
`false`. It stays styleless on purpose (ground rule 4: no shipped visual
identity).

Every real app built on this kit has then added roughly the same small
set to `app/widgets/`, early: a primary button, a card, a text field, a
snackbar helper, and a responsive-padding utility. Those *do* carry
styling decisions, so the kit doesn't ship them — but expect to build
them, put them in `app/widgets/`, and keep a one-feature widget in that
feature's own `presentation/widgets/`.

### The two traps

- **A "hollow" feature.** You make `features/location/` with
  `data/domain/` but an empty `presentation/` because it has no screen.
  That empty layer is the smell. If there's no screen, it's not a
  feature — it's a `core/service`.
- **A feature reaching into another feature.** `checkout` imports
  `features/cart/domain/...`. The moment you want to do this, the shared
  piece belongs in `core/` (infrastructure) or `core/models/` (a value
  type). Two features never depend on each other directly.

---

## Rules, in one place

**Dependency direction**
- `features/ → core/` only. Never `core/ → features/` (the one
  session-expiry exception is documented in ADR-0012).
- No feature imports another feature.
- Only `app/` imports from both `core/` and `features/`.
- Inside a feature: `presentation/ → domain/`, `data/ → domain/`.
  `presentation/` never imports `data/repositories/…Impl`.

**Structure**
- Every feature has `data/`, `domain/`, `presentation/`. No exceptions,
  no flat variant.
- Generate features with `mason make feature`. Don't hand-type the
  structure.
- One `GoRouter`. One `Dio`. One Hive `Box`. One `Logger`. All injected.

**State**
- One cubit per feature, one sealed state class. A second cubit needs a
  genuinely separate screen lifecycle to justify it.
- `if (isClosed) return;` after every real `await` before an `emit()`.
- A cubit that owns a `Timer` / `StreamSubscription` cancels it in
  `close()`.
- Pure animation is a `StatefulWidget`, not a DI-registered cubit.

**Errors**
- Repository methods return `Result<Failure, S>`. No throwing to a cubit,
  no `null` for failure.
- Raw backend error strings never become a `Failure` message. The only
  channel for a human-authored backend string is `MessageFailure`, and
  only when its origin is confirmed.

**Never do**
- Edit `di.config.dart` by hand.
- Add a second `GoRouter` or a parallel navigation mechanism.
- Build a second `Dio` or attach an interceptor outside `dio_client.dart`.
- Log a raw request/response body, or a state object's fields.
- Weaken the router's `unknown`-state guard.
- Introduce `melos.yaml` / a `packages/` split without the explicit
  Layer 4 migration.

If you have a real reason to break one of these, that's an ADR in
`docs/decisions/`, not a quiet deviation.

---

## The parts around the code

### Configuration and flavors

`config/development.json`, `config/staging.json`, `config/production.json`
are flat maps of `--dart-define` keys. `AppConfig` reads them at compile
time, each field defaulting to the `development.json` value — so plain
`flutter run` / `flutter test` need no flags. Run a specific environment
with `--dart-define-from-file=config/staging.json`. See ADR-0009.

`API_BASE_URL` must be an absolute URL. `Dio(BaseOptions(baseUrl: '/api'))`
throws on every non-web platform.

### Logging

Two independent switches, both on outside production:

- `ENABLE_NETWORK_LOGGING` → `LoggingInterceptor` (redacted request /
  response lines).
- `ENABLE_APP_FLOW_LOGGING` → `AppBlocObserver` (cubit
  create / transition / close) and `AppNavigatorObserver`
  (push / pop / replace). Type names and route names only.

One exception: `AppBlocObserver.onError` logs an uncaught cubit exception
regardless of the flag. That's a bug, not routine noise, and the kit has
no separate crash-reporting channel.

### Testing

- `flutter test` runs everything.
- `test/flutter_test_config.dart` loads real fonts before any test, so a
  golden test actually catches a typography regression instead of
  passing on a fallback glyph.
- Every feature ships at least: one cubit test (success + failure
  `Result` paths) and one widget test for the page.
- The kit's own infrastructure is tested too — the interceptor-count
  assertion, the `Result` fold, the session-expiry predicate, temp-file
  cleanup, `AppConfig` defaults.

### The two bricks

- **`core_init`** generates a whole project (this structure, both example
  features, tests, CI, the ADRs).
- **`feature`** generates one feature into an existing `core_init`
  project and wires its route. It's distributed as a git reference from
  the starter kit repo (ADR-0006), so `mason make feature` from inside a
  generated project resolves it over the network.

### Progressive disclosure, in practice

You are on Layers 0–3. The signal is the absence of `melos.yaml` at the
project root. Do not add multi-package structure by hand. If you reach
the point of two real apps sharing a core, run the Layer 4 migration
brick, which documents in its own ADR exactly when that move is
justified — the trigger is "two or more real apps", not "we might need it
one day".

---

## ADR index

The full reasoning behind each decision lives in `docs/decisions/`. Read
one only when you need the *why*.

| ADR | Decision |
|---|---|
| 0001 | DI via `get_it` + `injectable` |
| 0002 | Local storage via `hive_ce` (the maintained fork) |
| 0003 | Cold-start-safe router guard; `AuthStatusNotifier` as status-only plumbing |
| 0004 | Pinning `freezed` / `injectable_generator` to a stable analyzer graph |
| 0005 | Hand-written `Result<F, S>`; the `Failure` hierarchy and `MessageFailure` |
| 0006 | The `feature` brick ships via git reference |
| 0007 | A real `auth` feature, locally simulated by default |
| 0008 | Structured logging via the `logger` package |
| 0009 | Flavor config via `--dart-define-from-file` JSON |
| 0010 | `presentation/pages/` and `*Page` naming |
| 0011 | App-flow logging: bloc + navigator observers, repository exception logging |
| 0012 | `SessionExpiryInterceptor` is the default; refresh-token is the opt-in swap |
| 0013 | A valueless `AppSpacing` scale ships; the theme extension is no longer a throwaway |
| 0014 | Small shared helpers (`confirmDialog`, `unexpectedError`) and folder conventions carried back from downstream apps |

## Further reading

- `docs/QUICKSTART.md` — clone to running app in a few minutes.
- `docs/MIGRATION-PLAYBOOK.md` — moving an existing app onto this
  structure.
- `docs/PWA-CHECKLIST.md` — what a mobile-first Flutter app gets wrong on
  the web.
