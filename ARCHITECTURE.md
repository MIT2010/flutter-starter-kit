# Arsitektur Flutter Starter Kit

Dokumen ini menjelaskan starter kit ini secara menyeluruh: filosofinya,
bagaimana semua package saling terhubung, dan bagaimana satu request
mengalir dari tap tombol sampai balik lagi ke layar. Untuk *cara pakai*
sehari-hari (setup, command, struktur folder singkat), lihat
[README.md](README.md) di root — dokumen ini melengkapi, bukan
menggantikan. Untuk detail satu package/fitur tertentu, tiap folder
punya `README.md` sendiri yang ditautkan dari [Peta Dokumentasi](#peta-dokumentasi)
di bagian akhir.

## Daftar Isi

1. [Filosofi](#filosofi)
2. [Tech Stack](#tech-stack)
3. [Struktur Monorepo & Dependency Graph](#struktur-monorepo--dependency-graph)
4. [Pola Arsitektur: Clean Architecture + BLoC](#pola-arsitektur-clean-architecture--bloc)
5. [Alur Konkret: Login dari Tap sampai Balik ke Layar](#alur-konkret-login-dari-tap-sampai-balik-ke-layar)
6. [Dependency Injection](#dependency-injection)
7. [Error Handling](#error-handling)
8. [Networking](#networking)
9. [State Management](#state-management)
10. [Local Storage](#local-storage)
11. [Offline Support (Queue)](#offline-support-queue)
12. [Localization](#localization)
13. [Theming / Design System](#theming--design-system)
14. [Environment & Konfigurasi](#environment--konfigurasi)
15. [Logging & Monitoring](#logging--monitoring)
16. [Security](#security)
17. [Testing Strategy](#testing-strategy)
18. [CI/CD](#cicd)
19. [Menambah Fitur Baru](#menambah-fitur-baru)
20. [Fitur Lengkap vs Skeleton](#fitur-lengkap-vs-skeleton)
21. [Peta Dokumentasi](#peta-dokumentasi)

---

## Filosofi

Starter kit ini dibuat untuk satu tujuan: begitu kamu `git clone`, kamu
sudah punya arsitektur yang **terbukti jalan** — bukan sekadar boilerplate
kosong yang keliatan rapi di diagram tapi belum pernah benar-benar
dipakai. Buktinya ada dua fitur lengkap dan berjalan
([`feature_auth`](packages/features/feature_auth/README.md) dan
[`feature_assessment`](packages/features/feature_assessment/README.md))
yang membuktikan pola Clean Architecture + BLoC + Melos ini memang
scalable lintas fitur, bukan cuma cocok untuk satu contoh.

Prinsip yang dipegang:

- **Layer dipisah oleh tanggung jawab, bukan oleh dogma.** `data` bicara
  dengan dunia luar (API, storage), `domain` berisi aturan bisnis murni
  tanpa dependency Flutter, `presentation` merender UI dan bereaksi ke
  `domain`. Setiap fitur baru mengikuti pola yang sama persis — kalau kamu
  paham `feature_auth`, kamu paham semua fitur di sini.
- **Kegagalan adalah data, bukan exception yang menyebar.** Domain layer
  tidak pernah `throw` — Repository menangkap semua `Exception` dari data
  layer dan memetakannya jadi `Failure` lewat `Either<Failure, T>`
  (`fpdart`). Presentation layer tidak pernah kaget oleh error tak
  terduga; semua kemungkinan gagal sudah eksplisit di tipe return.
- **Ini starter kit, bukan platform enterprise siap-produksi-segala-skenario.**
  Beberapa keputusan sengaja disederhanakan (lihat [CI/CD](#cicd) dan
  [Security](#security)) dengan komentar eksplisit di kode tentang apa
  yang perlu ditambah kalau kebutuhanmu lebih kompleks — bukan
  diasumsikan di muka untuk semua orang.
- **Skeleton dibiarkan kosong dengan sengaja.** `feature_dashboard`,
  `feature_profile`, `feature_notification` tidak diisi implementasi
  palsu — itu tempat kamu mulai bekerja, dengan `pubspec.yaml` dan
  struktur folder yang sudah benar dari `feature_brick`.
- **Satu monorepo boleh berisi lebih dari satu app — selama masih satu
  produk.** `apps/main` adalah app pertama; `melos run app:new`
  (lihat bagian "Feature & App Scaffolding" di [README.md](README.md))
  menambah app lain yang tetap memakai `core`/`core_network`/
  `core_storage`/`core_ui`/`core_l10n` yang SAMA (bukan disalin). Cocok
  untuk kasus
  seperti satu app pengguna + satu app khusus staf/mitra untuk produk
  yang sama. Kalau appnya sebetulnya produk yang BEDA (bukan cuma peran
  pengguna yang beda), itu artinya butuh clone starter kit baru yang
  terpisah, bukan app kedua di monorepo yang sama.

## Tech Stack

| Kebutuhan | Pilihan | Alasan singkat |
|---|---|---|
| Monorepo | Melos 8 + Dart native workspace | Satu `pubspec.lock`, satu `pub get`, command lintas-package |
| State management | `flutter_bloc` / `bloc` | Event-driven, gampang di-test (`bloc_test`), state eksplisit |
| Error handling | `fpdart` (`Either<Failure, T>`) | Railway-oriented, tidak ada exception nyasar ke UI |
| HTTP client | `dio` | Interceptor chain, cocok untuk auth-refresh & logging terpusat |
| DI | `get_it` (manual) | Simpel, tidak perlu code-gen (`injectable` sengaja tidak dipakai) |
| Local storage | `hive_ce_flutter` + `flutter_secure_storage` | Cache cepat (Hive) terpisah dari data sensitif (Secure Storage) |
| Localization | `slang` | Type-safe (`context.t.auth.login`), bukan ARB/`intl` |
| Routing | `go_router` | Deklaratif, redirect guard bawaan |
| Mocking | `mockito` + `build_runner` | Mock digenerate dari abstract class, bukan ditulis manual |
| Crash reporting | `sentry_flutter` (opsional) | Aktif hanya kalau `SENTRY_DSN` diisi |
| Realtime | `flutter_secure_app` (Reverb/Pusher client custom, lihat `ReverbManager`) | WebSocket untuk broadcast event dari Laravel Reverb |
| Scaffolding | Mason (`feature_brick`, `test_brick`) | Generate fitur baru dengan struktur yang konsisten |

## Struktur Monorepo & Dependency Graph

13 package dalam satu Dart workspace (`pubspec.yaml` root, field
`workspace:`), diresolusi jadi **satu** `pubspec.lock` di root — bukan
satu lockfile per package.

```
apps/main                  → composition root (satu-satunya yang "tahu" semua fitur)

packages/
├── core                   → error/failure, env, logger, DI container, utils
├── core_network           → ApiClient (Dio), interceptors, offline-queue orchestrator, WebSocket
├── core_storage           → HiveStorage<T>, SecureStorage, primitif queue (QueueItem/QueueStorage)
├── core_ui                → design system: tokens, theme, komponen
├── core_l10n              → terjemahan (slang) — id/en
├── shared/
│   ├── shared_auth        → UserEntity, SessionManager (contract)
│   └── shared_assessment  → entity assessment (sealed class untuk 4 tipe soal/jawaban)
└── features/
    ├── feature_auth         → ✅ lengkap — login, OTP, session
    ├── feature_assessment   → ✅ lengkap — intro, soal, submit, resume offline
    ├── feature_dashboard    → 🔲 skeleton
    ├── feature_profile      → 🔲 skeleton
    └── feature_notification → 🔲 skeleton
```

Aturan dependency (siapa boleh import siapa):

```
apps/main
   └─→ features/*  ─┐
   └─→ shared/*     ├─→ core, core_network, core_storage, core_ui, core_l10n
                     ┘
core_network ─→ core         (Failure/Exception, AppEnv, AppLogger)
core_storage ─→ core
core_ui      ─→ (tidak bergantung ke package lain di repo ini)
core_l10n    ─→ (tidak bergantung ke package lain di repo ini)
features/*   ─→ core, core_network, core_storage, core_ui, shared/* yang relevan
```

`core`, `core_ui`, `core_l10n` tidak pernah bergantung balik ke
`features/*` atau `shared/*` — arah dependency selalu dari yang spesifik
ke yang generic, tidak pernah sebaliknya. Ini yang membuat setiap
`core_*` package bisa di-`flutter test` sendiri tanpa perlu tahu fitur
apa saja yang memakainya.

## Pola Arsitektur: Clean Architecture + BLoC

Setiap fitur (`features/feature_xxx`) dan tiap package `shared_xxx`
mengikuti tiga layer yang sama, ditunjukkan lewat struktur folder nyata
`feature_auth`:

```
lib/src/
├── data/
│   ├── auth_endpoints.dart              # konstanta path API — satu file, gampang diubah
│   ├── models/                          # fromJson/toEntity() — bentuk mentah dari API/cache
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart  # abstract + Impl, panggil ApiClient
│   │   └── auth_local_datasource.dart   # abstract + Impl, panggil SecureStorage
│   └── repositories/
│       └── auth_repository_impl.dart    # implementasi kontrak domain, try/catch di sini
├── domain/
│   ├── entities/                        # model bersih, tidak tahu JSON/HTTP sama sekali
│   ├── repositories/
│   │   └── auth_repository.dart         # abstract contract — dipakai use case, di-mock di test
│   └── usecases/
│       └── login_with_email_password_usecase.dart  # satu class = satu aksi bisnis
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart    # terima Event, panggil use case, emit State
    │   ├── auth_event.dart   # part of — semua kemungkinan aksi user
    │   └── auth_state.dart   # part of — semua kemungkinan tampilan UI
    ├── pages/                # widget yang di-route, provide BLoC
    └── widgets/              # widget anak, terima data lewat constructor
```

Aturan yang dipegang konsisten di seluruh repo:

- **`domain` tidak pernah import Flutter, Dio, atau Hive.** Murni Dart +
  `equatable` + `fpdart`. Ini yang membuat use case bisa di-unit-test tanpa
  widget test harness.
- **Repository adalah satu-satunya tempat `try/catch` terhadap
  `AppException`.** Pola tetap:
  ```dart
  if (!await _networkInfo.isConnected) return Either.left(const NetworkFailure());
  try {
    final model = await _remote.doSomething();
    return Either.right(model.toEntity());
  } on UnauthorizedException catch (e) {
    return Either.left(UnauthorizedFailure(message: e.message));
  } on ServerException catch (e) {
    return Either.left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    AppLogger.error('XxxRepository error', e);
    return Either.left(UnknownFailure(message: e.toString()));
  }
  ```
- **BLoC tidak pernah bicara langsung ke Repository** — selalu lewat use
  case. Use case = satu tanggung jawab bisnis, gampang di-mock satu-satu
  di test BLoC.
- **Sealed class untuk state yang bercabang secara alami.** Contoh nyata:
  `QuestionEntity` dan `UserAnswerEntity` di `shared_assessment` masing-masing
  4 varian (single/multiple choice, matrix, open-ended) — `switch`
  exhaustive di compile-time, tidak ada `default:` yang menyembunyikan
  kasus baru yang lupa ditangani.

## Alur Konkret: Login dari Tap sampai Balik ke Layar

Supaya semua konsep di atas terasa konkret, ini urutan pemanggilan
nyata saat user menekan tombol "Login" di `feature_auth`:

1. `EmailPasswordForm` (widget) memanggil
   `context.read<AuthBloc>().add(AuthLoginWithEmailPasswordEvent(email, password))`.
2. `AuthBloc` menerima event, emit `AuthLoading()`, lalu memanggil
   `_loginWithEmailPassword(LoginParams(email, password))` —
   `LoginWithEmailPasswordUseCase` yang di-inject lewat constructor.
3. Use case validasi input dasar (email/password tidak kosong) — kalau
   invalid, langsung `Either.left(ValidationFailure(...))` tanpa
   menyentuh network sama sekali.
4. Kalau valid, use case memanggil
   `_repository.loginWithEmailPassword(email, password)` —
   `AuthRepositoryImpl`.
5. Repository cek `NetworkInfo.isConnected` dulu; kalau offline langsung
   `Either.left(NetworkFailure())`. Kalau online, panggil
   `AuthRemoteDataSource.login(...)`.
6. Datasource memanggil `ApiClient.post('/auth/login', data: {...})`.
   Dio menjalankan interceptor chain (lihat [Networking](#networking)):
   Security → Auth (attach token kalau ada) → kirim ke server → Error
   (mapping status code jadi `AppException`) → Logging.
7. Response sukses dipetakan `AuthTokenModel.fromJson(...)`, disimpan ke
   `AuthLocalDataSource` (via `SecureStorage`), dikembalikan sebagai
   `AuthTokenEntity` lewat `.toEntity()`.
8. Repository bungkus jadi `Either.right(token)`, mengalir balik lewat
   use case ke BLoC.
9. `AuthBloc` pattern-match hasil `Either`: `Right` → emit
   `AuthAuthenticated(user)`; `Left` → emit `AuthError(failure.message)`.
10. `LoginPage` (via `BlocBuilder`/`BlocListener`) merender ulang sesuai
    state baru. Terpisah dari itu, `AppRouter._authGuard` (dipanggil
    `go_router` di setiap navigasi) melihat state `AuthBloc` yang sama
    dan redirect ke `/home` kalau sudah `AuthAuthenticated`.

Tidak ada langkah di atas yang "ajaib" atau tersembunyi di balik
annotation/code-gen — semuanya bisa ditelusuri dengan Ctrl+Click dari
`login_page.dart` sampai `auth_repository_impl.dart`.

## Dependency Injection

Manual, pakai [`get_it`](https://pub.dev/packages/get_it) (variabel
global `getIt` dari package `core`) — **bukan** `injectable`, meskipun
dependency-nya pernah ada di beberapa `pubspec.yaml` secara historis
(sudah dibersihkan; kalau masih menemukan sisa referensinya di tempat
lain, itu artefak lama, bukan pola yang dipakai).

Semua registrasi ada di **satu file**:
[`apps/main/lib/core/di/injection.dart`](apps/main/lib/core/di/injection.dart),
dikelompokkan per section dengan komentar (`── Core ──`, `── Offline
Queue ──`, `── Feature Assessment ──`, `── Feature Auth ──`). Urutan di
dalam file ini penting — misalnya `ApiClient` butuh `SessionManager`
untuk callback `getAccessToken`, jadi `SessionManager` didaftarkan lebih
dulu.

Pola standar per fitur: `registerSingleton` untuk datasource/repository
(stateful, satu instance untuk seluruh app lifetime), `registerFactory`
untuk use case (stateless, murah dibuat berkali-kali, dan factory
membuat test lebih mudah karena tidak ada instance lama yang ke-cache).

Kalau menambah fitur baru, tambahkan section baru dengan pola yang
sama. `feature_brick` (Mason) sudah generate struktur yang cocok
langsung disambungkan ke sini.

## Error Handling

Dua tingkat representasi error, sengaja dipisah:

- **`AppException`** (di data layer) — bentuk mentah error teknis:
  `NetworkException`, `ServerException`, `UnauthorizedException`,
  `CacheException`, dll. Dilempar oleh datasource, ditangkap oleh
  repository.
- **`Failure`** (di domain layer, `Equatable`) — bentuk yang dimengerti
  UI: `NetworkFailure`, `ServerFailure(message, statusCode)`,
  `UnauthorizedFailure`, `NotFoundFailure`, `CacheFailure`,
  `ValidationFailure(message, messages)`, `UnknownFailure`. Semua pesan
  defaultnya sudah dalam Bahasa Indonesia yang siap ditampilkan ke user.

Repository adalah satu-satunya jembatan antara keduanya (lihat pola di
[bagian arsitektur](#pola-arsitektur-clean-architecture--bloc) di atas).
Presentation layer **tidak pernah** menangkap `Exception` — kalau BLoC
menemukan dirinya butuh `try/catch`, itu tanda ada `Exception` yang
lolos dari repository dan perlu dipetakan ke `Failure` di sana, bukan
di-workaround di BLoC.

Return type domain: `FutureEither<T>` (typedef untuk
`Future<Either<Failure, T>>`, ada di `core`), dipakai konsisten di
seluruh use case dan repository contract.

## Networking

[`ApiClient`](packages/core_network/lib/src/http/api_client.dart)
(wrapper `Dio`) adalah satu-satunya cara fitur bicara ke backend — tidak
ada fitur yang membuat `Dio` instance sendiri. Interceptor chain,
urutan tetap:

1. **`SecurityInterceptor`** — cek `AppSecurityGuard.isSafe` (RASP),
   blokir request kalau device terdeteksi tidak aman. Di-skip otomatis
   saat development kecuali diaktifkan eksplisit.
2. **`AuthInterceptor`** — attach access token ke header. Kalau server
   balas 401, otomatis panggil `refreshToken` callback **sekali**
   (di-dedup lewat `_refreshInFlight` supaya request paralel yang
   sama-sama kena 401 tidak memicu banyak refresh sekaligus), lalu
   retry request asli.
3. **`ErrorInterceptor`** — memetakan `DioException`/status code jadi
   `AppException` yang konsisten, supaya repository tidak perlu tahu
   detail Dio sama sekali.
4. **`LoggingInterceptor`** — log request/response, aktif sesuai
   `AppEnv.enableLogs`.

Certificate pinning (`CertificatePinning.apply()`,
`certificate_pinning_interceptor.dart`) tersedia tapi **tidak aktif
secara default** — ada catatan eksplisit di kodenya kenapa (fingerprint
Let's Encrypt berubah tiap 90 hari, butuh proses CI untuk update
otomatis kalau mau dipakai serius).

Selain HTTP, ada [`ReverbManager`](packages/core_network/lib/src/websocket/reverb_manager.dart)
untuk koneksi WebSocket ke [Laravel Reverb](https://reverb.laravel.com/)
(broadcast event realtime) — terpisah dari `ApiClient` karena protokolnya
beda, tapi memakai `AppEnv` yang sama untuk konfigurasi host/port/app key.

## State Management

`flutter_bloc`/`bloc` di semua fitur. Konvensi:

- Satu file `_bloc.dart` + dua file `part of` (`_event.dart`,
  `_state.dart`) — bukan file terpisah tanpa `part`, supaya event/state
  yang saling terkait tetap terasa satu kesatuan saat dibaca.
- Event dan State sama-sama `Equatable` (atau sealed class kalau
  variannya perlu membawa data berbeda-beda, lihat `AssessmentState`).
- BLoC diberi use case lewat constructor (bukan lookup `getIt` di dalam
  BLoC) — ini yang membuat `bloc_test` bisa mock use case satu-satu
  tanpa menyentuh DI container sama sekali.
- `AppBlocObserver` ([apps/main/lib/core/observer](apps/main/lib/core/observer/app_bloc_observer.dart))
  mencatat semua transisi event/state/error lewat `AppLogger` — berguna
  untuk debugging tanpa perlu `print()` manual di tiap BLoC.

## Local Storage

Dua mekanisme, dipisah tegas berdasarkan sensitivitas data:

- **`HiveStorage<T>`** ([core_storage](packages/core_storage/README.md))
  — cache generic berbasis Hive CE, untuk data yang aman disimpan
  plain (hasil API yang sudah publik, progress sesi assessment). Karena
  Hive butuh tipe primitif atau `TypeAdapter` ter-registrasi (repo ini
  tidak pakai `@HiveType` code-gen), pola yang dipakai konsisten adalah
  simpan sebagai `String` hasil `jsonEncode`, baca balik dengan
  `jsonDecode`.
- **`SecureStorage`** (`flutter_secure_storage`) — untuk data sensitif:
  access token, refresh token. Dipakai oleh `AuthLocalDataSource`.

## Offline Support (Queue)

Sistem antrian generik untuk operasi yang harus tetap terkirim meski
user sedang offline saat itu (contoh nyata: submit jawaban assessment).
Empat bagian, tanggung jawab terpisah:

- **`QueueItem`** / **`QueueStorage`** (`core_storage`) — struktur data
  satu item antrian + persistensinya (Hive, `Box<String>` + JSON).
- **`RetryPolicy`** (`core_network`, sealed class) — `unlimited()` untuk
  data kritis yang tidak boleh hilang (jawaban assessment), `limited(maxAttempts)`
  untuk operasi non-kritis. Keduanya sama-sama pakai exponential backoff
  (`2^attempt` detik, dibatasi maksimal 60 detik) lewat
  `delayForAttempt()`.
- **`QueueHandler`** (`core_network`, abstract contract) — satu per tipe
  operasi (`type` unik), diimplementasikan per fitur untuk tahu cara
  mengirim data spesifiknya ke API. `AnswerQueueHandler` di
  `feature_assessment` adalah contoh konkretnya.
- **`QueueSyncManager`** (`core_network`) — orkestrator: dengar
  perubahan konektivitas (`NetworkInfo`), jalankan handler yang cocok
  untuk tiap item saat online, jadwalkan retry dengan backoff timer
  kalau gagal, hentikan retry (dan buang item) kalau `RetryPolicy`
  bilang sudah tidak boleh lagi.

Dua instance `QueueSyncManager` didaftarkan di DI:
`instanceName: 'assessmentQueue'` (unlimited retry, sudah ada handler)
dan `instanceName: 'genericQueue'` (limited retry, belum ada handler
terdaftar — siap dipakai fitur berikutnya yang butuh, misalnya update
profile offline).

## Localization

[`slang`](https://pub.dev/packages/slang) — **bukan** ARB/`flutter
gen-l10n`. Sumber teks di
[`packages/core_l10n/lib/i18n/{id,en}.i18n.json`](packages/core_l10n/lib/i18n/),
di-generate jadi kode Dart type-safe lewat `melos run gen:l10n`
(`dart run slang` di dalam `core_l10n`). Hasil generate
(`strings.g.dart` dkk) di-gitignore — selalu jalankan generate setelah
clone atau setelah mengubah file JSON.

Dipakai di widget lewat `context.t.namespace.key` (contoh:
`context.t.auth.welcomeBack`, `context.t.assessment.startTest`) —
typo di key ketahuan saat compile, bukan saat runtime seperti ARB.
`apps/main` membungkus root widget dengan `TranslationProvider` dan
memakai `AppLocaleUtils.supportedLocales` untuk
`MaterialApp.supportedLocales`.

## Theming / Design System

[`core_ui`](packages/core_ui/README.md) — token-based, Material 3:

- `tokens/` — `AppColors`, `AppSpacing`, `AppTypography`: nilai mentah,
  tidak tahu konteks pemakaian.
- `theme/app_theme.dart` — `AppTheme.light`/`AppTheme.dark`, merakit
  token jadi `ThemeData` lengkap (app bar, button, input, card, divider,
  bottom nav, chip).
- `components/` — widget kecil reusable (`AppBadge`, `AppCard`,
  `AppDivider`, `AppText`).
- `patterns/` — widget dengan perilaku (`AppButton`, `AppTextField`,
  `AppLoading`, `AppEmptyView`, `AppErrorView`) — dipakai konsisten di
  `feature_auth` dan `feature_assessment` supaya tampilan loading/error
  seragam lintas fitur tanpa perlu diulang tiap halaman.

## Environment & Konfigurasi

Tiga flavor (`development`, `staging`, `production`), masing-masing:

- Entry point sendiri: `main.dart`, `main_staging.dart`,
  `main_production.dart` — isinya cuma memanggil
  `bootstrap(flavor: AppFlavor.xxx)`.
- File config sendiri: `config/{development,staging,production}.json`,
  dibaca lewat `--dart-define-from-file` saat `flutter run`/`build`.
  File asli **tidak di-commit** (lihat `.gitignore`) — `melos run setup`
  otomatis copy dari `config/*.example.json` kalau belum ada
  (`ensureConfigFiles()` di `tools/scripts/rename_project.dart`).
- Dibaca lewat `AppEnv` (`packages/core/lib/src/env/app_env.dart`),
  semua `static const` dari `String.fromEnvironment`/`bool.fromEnvironment`
  dengan default value yang aman — app tidak crash meski lupa mengisi
  config, hanya jatuh ke default development-friendly.

`AppFlavor` (enum: `development`/`staging`/`production`) menentukan
keputusan runtime yang tidak datang dari file config, misalnya sample
rate Sentry (`flavor.isProduction ? 0.2 : 1.0`).

## Logging & Monitoring

`AppLogger` (`core`, wrapper `talker`) dipakai di seluruh layer untuk
logging terstruktur (`.info`, `.warning`, `.error`, `.critical`) —
tidak ada `print()` tersebar (lint `avoid_print` aktif, lihat
[Testing Strategy](#testing-strategy)).

Crash reporting (Sentry) **opsional**, aktif hanya kalau `SENTRY_DSN`
diisi di config (`AppEnv.hasSentry`). Desain sengaja menjaga `core`
tetap bebas dependency Sentry: `AppLogger.registerErrorReporter(...)`
adalah hook yang didaftarkan dari `apps/main/lib/bootstrap.dart` saat
runtime, bukan import langsung. Kalau `SENTRY_DSN` kosong, error tetap
tercatat lokal lewat `AppLogger` seperti biasa — tidak ada perilaku yang
"diam-diam hilang" hanya karena belum setup Sentry.

## Security

Beberapa lapis, semuanya dengan sikap yang sama seperti di
[Filosofi](#filosofi): aktif kalau relevan, dijelaskan kalau tidak
diaktifkan secara default, tidak dipaksakan sebagai satu-satunya cara
benar.

- **RASP** (`AppSecurityGuard`, via `flutter_secure_app`) — deteksi
  root/jailbreak, diinisialisasi sekali di bootstrap
  (`AppSecurityGuard.init()`), lalu `SecurityInterceptor` memblokir
  request kalau `isSafe == false`. Otomatis di-skip di Web (tidak ada
  konsep root/jailbreak untuk PWA).
- **Certificate pinning** — tersedia (`CertificatePinning.apply()`)
  tapi **opt-in**, tidak dipasang otomatis ke `ApiClient`. Lihat catatan
  di [Networking](#networking).
- **Secure storage** — token disimpan lewat `flutter_secure_storage`
  (Keychain/Keystore), bukan `SharedPreferences`/Hive biasa.
- **Code obfuscation** — `melos run build:android:prod`/`build:ios:prod`
  memakai `--obfuscate --split-debug-info`. Simbol debug **tidak**
  di-commit ke git biasa (lihat komentar di `.gitignore`) — perlu
  disimpan terpisah (secrets manager/private bucket) untuk
  de-obfuscate crash report production nanti.
- **Android release signing** — `key.properties`-based (pola resmi
  Flutter), fallback ke debug key kalau `key.properties` belum ada.
  Copy dari `apps/main/android/key.properties.example`.

## Testing Strategy

- **Unit test** (`test/unit/`) — use case dan BLoC, mock repository/use
  case lewat `mockito` (`@GenerateMocks`, generate dengan
  `melos run gen`). BLoC test pakai `bloc_test` package, termasuk
  `seed:`/`skip:` untuk kasus transisi state yang bergantung state
  sebelumnya.
- **Widget test** (`test/widget/`, baru ada di `apps/main`) — smoke test
  yang benar-benar pump widget tree, bukan cuma unit-test logic-nya.
- **Lint** — `flutter_lints` aktif di **semua** package lewat
  `analysis_options.yaml` masing-masing (`include: package:flutter_lints/flutter.yaml`),
  dijalankan lewat `melos run analyze`/`melos run lint`.
- Script terkait di root `pubspec.yaml`:
  ```bash
  melos run test          # semua test/unit/ di seluruh workspace
  melos run test:widget   # semua test/widget/ di seluruh workspace
  melos run gen           # generate .mocks.dart (build_runner)
  ./tools/scripts/generate_test.sh <nama_fitur>  # scaffold test/unit baru (Mason test_brick)
  ```

## CI/CD

Dua workflow terpisah, keduanya di `.github/workflows/`:

- **`ci.yml`** — jalan di tiap push/PR ke `main`/`develop`. Urutan
  step penting dan sengaja diurutkan begini: `pub get` → `gen:l10n` →
  `gen` (mocks) → `format:check` → `analyze` → `test` → `test:widget`.
  L10n dan mocks harus digenerate **sebelum** analyze/test karena
  keduanya gitignored (`strings.g.dart`, `*.mocks.dart`) — checkout
  fresh tidak akan punya file-file itu sama sekali sampai step generate
  jalan.
- **`build.yml`** — sengaja **hanya** build flavor staging (Android APK
  + Web), upload sebagai artifact. `config/staging.json` gitignored jadi
  tidak ada di checkout CI — direkonstruksi dari secret
  `STAGING_CONFIG_JSON` (isi = seluruh isi file `config/staging.json`
  kamu) sebelum build, lalu dipakai lewat `--dart-define-from-file`
  supaya hasil build CI **sama persis** dengan `melos run build:*:staging`
  di lokal (sebelumnya cuma 3 dari 10 key yang di-pass satu-satu lewat
  `--dart-define`, jadi `WS_APP_KEY`/`SENTRY_DSN`/dkk kosong tanpa
  disadari). Ada catatan eksplisit di file itu kenapa production build
  tidak diasumsikan di sini (strategi rilis beda-beda per project — Play
  Store vs internal distribution vs Fastlane, dll) dan groundwork apa
  yang sudah tersedia kalau kamu siap menambahkannya sendiri (command
  `build:*:prod` di melos, signing Android via `key.properties`).

## Menambah Fitur Baru

```bash
melos run feature:new
# Mason akan prompt nama fitur (snake_case), generate:
#   packages/features/feature_<nama>/
#   dengan struktur data/domain/presentation lengkap + analysis_options.yaml
```

Langkah setelah generate (lihat juga [README.md](README.md) bagian
"Menambah Feature Baru" untuk versi ringkas dengan urutan lengkap):

1. Daftarkan ke `workspace:` di root `pubspec.yaml`.
2. Daftarkan sebagai dependency di `apps/main/pubspec.yaml`.
3. Isi data layer (`models/`, `datasources/`, `repositories/`) sesuai
   API sungguhan — template generate skeleton dengan `TODO` di
   titik-titik yang perlu disesuaikan.
4. Registrasikan ke DI (`apps/main/lib/core/di/injection.dart`) —
   section baru mengikuti pola fitur lain.
5. Tambahkan route (`apps/main/lib/core/router/app_router.dart`).
6. `melos run gen` untuk generate mock, lalu
   `./tools/scripts/generate_test.sh <nama>` untuk scaffold unit test
   (Mason `test_brick`).

Kedua brick (`feature_brick`, `test_brick`) polanya diambil langsung
dari `feature_auth`/`feature_assessment` yang sudah terbukti jalan —
bukan ditulis terpisah dari kode nyata, jadi kalau kamu ubah pola di
salah satu fitur referensi, pertimbangkan apakah brick-nya perlu
diperbarui juga.

## Fitur Lengkap vs Skeleton

| Fitur | Status | Kegunaan |
|---|---|---|
| `feature_auth` | ✅ Lengkap | Referensi utama pola HTTP + session. Login email/password, OTP, refresh token, logout. |
| `feature_assessment` | ✅ Lengkap | Referensi kedua — membuktikan pola di atas scalable. Intro → soal (4 tipe via sealed class) → submit (lewat offline queue) → resume (via `HiveStorage`) → complete. |
| `feature_dashboard` | 🔲 Skeleton | Struktur folder + `pubspec.yaml` benar, siap diisi. Saat ini `/home` masih `_PlaceholderHome` di `app_router.dart`. |
| `feature_profile` | 🔲 Skeleton | Sama seperti di atas. |
| `feature_notification` | 🔲 Skeleton | Sama seperti di atas. |

Skeleton di sini **bukan bug** — mengisi ketiganya dengan implementasi
palsu hanya akan menambah kode yang harus dihapus lagi. Kalau kamu
butuh contoh pola CRUD sederhana (tanpa offline queue/sealed class),
`feature_auth` sudah cukup sebagai referensi; kalau butuh contoh pola
lebih kompleks (queue, resume, sealed class polymorphic),
`feature_assessment` referensinya.

## Peta Dokumentasi

| Dokumen | Isi |
|---|---|
| [README.md](README.md) | Quick start, command sehari-hari, struktur folder ringkas |
| **ARCHITECTURE.md** (dokumen ini) | Gambaran arsitektur menyeluruh, alur data, keputusan desain |
| [apps/main/README.md](apps/main/README.md) | Composition root: bootstrap, DI, routing |
| [packages/core/README.md](packages/core/README.md) | Failure/Exception, AppEnv, AppLogger, utils |
| [packages/core_network/README.md](packages/core_network/README.md) | ApiClient, interceptors, queue orchestrator, security |
| [packages/core_storage/README.md](packages/core_storage/README.md) | HiveStorage, SecureStorage, primitif queue |
| [packages/core_ui/README.md](packages/core_ui/README.md) | Design system — token, theme, komponen |
| [packages/core_l10n/README.md](packages/core_l10n/README.md) | Localization dengan slang |
| [packages/shared/shared_auth/README.md](packages/shared/shared_auth/README.md) | Kontrak & entity auth lintas fitur |
| [packages/shared/shared_assessment/README.md](packages/shared/shared_assessment/README.md) | Entity assessment (sealed class) |
| [packages/features/feature_auth/README.md](packages/features/feature_auth/README.md) | Fitur referensi #1 |
| [packages/features/feature_assessment/README.md](packages/features/feature_assessment/README.md) | Fitur referensi #2 |
| [packages/features/feature_dashboard/README.md](packages/features/feature_dashboard/README.md), [feature_profile](packages/features/feature_profile/README.md), [feature_notification](packages/features/feature_notification/README.md) | Status skeleton, cara mulai isi |
