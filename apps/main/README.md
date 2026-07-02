# apps/main

Entry point aplikasi — composition root yang menyatukan semua package
di `packages/` jadi satu app Android/iOS/PWA. Untuk gambaran umum
workspace dan cara setup, lihat `README.md` di root repo. File ini
fokus ke isi `apps/main` sendiri.

## Struktur

```
lib/
├── main.dart                # entry point development
├── main_staging.dart         # entry point staging
├── main_production.dart      # entry point production
├── bootstrap.dart             # urutan inisialisasi (lihat di bawah)
├── app.dart                   # MaterialApp.router + theme + locale
└── core/
    ├── di/injection.dart       # semua registrasi get_it (satu file, per-fitur per-section)
    ├── router/app_router.dart  # go_router + auth guard
    └── observer/app_bloc_observer.dart  # log semua event/state/error BLoC

test/
└── widget_test.dart           # smoke test: LoginPage merender dengan benar
```

Tiga entry point (`main*.dart`) semuanya cuma memanggil
`bootstrap(flavor: AppFlavor.xxx)` — beda `AppFlavor` menentukan
`--dart-define-from-file` mana yang dipakai (lihat `melos run run:dev`
dkk di root `pubspec.yaml`) dan beberapa keputusan runtime (verbose
logging, sample rate Sentry).

## Urutan bootstrap

`bootstrap()` menjalankan, berurutan:

1. `WidgetsFlutterBinding.ensureInitialized()` + kunci orientasi portrait.
2. `AppLogger.init()` — logger aktif sebelum apa pun lain (biar semua step
   berikutnya bisa log).
3. `AppSecurityGuard.init()` — RASP, jalan sebelum request network apa pun.
4. `Bloc.observer = AppBlocObserver()`.
5. `AppStorage.init()` — Hive siap dipakai.
6. `configureDependencies()` — semua `getIt.registerXxx` (lihat
   `core/di/injection.dart`).
7. `LocaleSettings.useDeviceLocale()` — locale aktif ditentukan dari device.
8. Crash reporting: kalau `AppEnv.hasSentry`, `SentryFlutter.init(...)`
   membungkus `runApp` (otomatis capture `FlutterError`/uncaught error);
   kalau tidak, `FlutterError.onError` diarahkan ke `AppLogger.error`
   seperti biasa (dev, `SENTRY_DSN` kosong).

## Dependency Injection

Manual, pakai `get_it` (`getIt` dari package `core`) — **bukan**
`injectable` meski secara historis pernah dipertimbangkan (tidak
dipakai, jangan tertipu kalau melihat sisa referensinya di tempat
lain). Semua registrasi ada di satu file,
`core/di/injection.dart`, dikelompokkan per-bagian dengan komentar:

```
── Core ──────────────────────────────────────────────────
── Offline Queue ─────────────────────────────────────────
── Feature Assessment ────────────────────────────────────
── Feature Auth ──────────────────────────────────────────
```

Kalau menambah fitur baru, tambahkan section baru dengan pola yang
sama: datasource → repository → use case, semua lewat
`getIt.registerSingleton`/`registerFactory`. File ini akan makin
panjang seiring fitur bertambah — kalau sudah terasa tidak terkelola
(misal setelah fitur ke-4/5), pertimbangkan memecahnya jadi
`_registerXxxDependencies()` per fitur, tapi untuk 2 fitur saat ini
belum perlu.

## Routing

`AppRouter` (go_router) — `AuthBloc` di-instansiasi sekali sebagai
`static final` dan hidup sepanjang umur app (bukan per-halaman), lalu
`_authGuard` melakukan redirect berdasarkan state-nya:

| Route | Guard |
|---|---|
| `/login` | Redirect ke `/home` kalau sudah `AuthAuthenticated` |
| `/home` | Placeholder — redirect ke `/login` kalau `AuthUnauthenticated` |
| `/assessment/:id` | `AssessmentBloc` baru dibuat tiap kunjungan (bukan static), auto-dispatch `AssessmentLoadRequested` |

`/home` masih placeholder (`_PlaceholderHome`) karena belum ada
`feature_dashboard` — ada tombol sementara untuk masuk ke satu
assessment demo (`demo-assessment`) supaya `feature_assessment` bisa
dicoba tanpa perlu halaman daftar tes.

## Testing

```bash
flutter test test/widget_test.dart
```

Satu smoke test: pump `LoginPage` (use case di-mock, mengikuti pola
`feature_auth`'s `auth_bloc_test.dart`) dibungkus `TranslationProvider`,
lalu pastikan form email/password beneran muncul. Catatan: file ini ada
langsung di `test/`, bukan `test/unit/` atau `test/widget/`, jadi
**tidak** ikut ter-cover oleh script `melos run test`/`test:widget` di
root — jalankan langsung seperti di atas.
