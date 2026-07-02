# core

Infrastruktur dasar yang dipakai oleh hampir setiap package lain di
workspace ini: error handling, konfigurasi environment, dependency
injection, logger, dan utility functions. Package ini sengaja tidak
bergantung pada package lain di workspace — semua package lain yang
bergantung padanya, bukan sebaliknya.

## Struktur

```
lib/
├── core.dart                   # barrel export
└── src/
    ├── error/
    │   ├── exceptions.dart      # AppException & subclass — data layer
    │   └── failure.dart         # Failure & subclass — domain layer
    ├── env/
    │   ├── app_env.dart         # baca --dart-define-from-file
    │   └── app_flavor.dart      # enum development/staging/production
    ├── di/
    │   └── injection.dart       # instance GetIt global (getIt)
    ├── logger/
    │   └── app_logger.dart      # wrapper Talker + hook error reporter eksternal
    └── utils/
        ├── date_utils.dart
        ├── number_utils.dart
        ├── string_utils.dart
        └── typedefs.dart        # FutureEither, re-export fpdart

test/unit/                       # string/number/date utils, Failure, AppException
```

## Error handling: Exception vs Failure

Dua hierarki paralel, sengaja dipisah menurut layer Clean Architecture:

- **`AppException`** (data layer) — dilempar oleh datasource/API client saat
  operasi gagal. Subclass: `NetworkException`, `ServerException`,
  `UnauthorizedException`, `NotFoundException`, `ValidationException`,
  `CacheException`. Semua membawa `message` dan `statusCode` opsional.
- **`Failure`** (domain layer) — hasil `Either.left(...)` yang dikembalikan
  repository ke use case. Subclass paralel dengan `AppException`:
  `NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`,
  `NotFoundFailure`, `CacheFailure`, `ValidationFailure`, `UnknownFailure`.
  Semua `extends Equatable` supaya gampang dibandingkan di test.

Pola standarnya: repository (`*RepositoryImpl`) memanggil datasource di
dalam `try/catch`, menangkap `AppException` spesifik, lalu mengonversinya
jadi `Failure` yang sesuai sebelum dikembalikan ke domain layer. Lihat
contoh nyata di `feature_auth`/`feature_assessment` — `data/repositories/
*_repository_impl.dart`.

`typedefs.dart` menyediakan shorthand supaya tanda tangan fungsi di
domain layer tidak berulang-ulang menulis `Future<Either<Failure, T>>`:

```dart
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = Future<Either<Failure, Unit>>;
```

`Either`, `Left`, `Right`, `Unit`, `left`, `right`, `unit` dari
[fpdart](https://pub.dev/packages/fpdart) ikut di-export lewat file yang
sama, jadi cukup `import 'package:core/core.dart';` di mana pun butuh
`Either`.

## Environment (`AppEnv`)

Semua nilai dibaca lewat `String.fromEnvironment`/`bool.fromEnvironment`
dari `--dart-define-from-file` (lihat `config/*.json` di root repo),
tidak pernah di-hardcode di kode. Field yang tersedia: `environment`,
`appName`, `baseUrl`, `wsUrl`, `wsPort`, `wsAppKey`, `wsAuthEndpoint`,
`sentryDsn`, `enableLogs`, `enableDevtools`, plus helper boolean
`isDevelopment`/`isStaging`/`isProduction`/`hasSentry`.

`AppFlavor` (enum `development`/`staging`/`production`) dipakai di
`apps/main`'s tiga entry point (`main.dart`, `main_staging.dart`,
`main_production.dart`) untuk memberi tahu `bootstrap()` flavor mana
yang aktif — dipakai antara lain untuk menentukan verbose logging dan
sample rate Sentry.

## Dependency Injection (`getIt`)

Package ini cuma menyediakan **instance** `GetIt` global (`getIt`).
Registrasi sesungguhnya (`registerSingleton`/`registerFactory` untuk
tiap service, repository, dan use case) ada di
`apps/main/lib/core/di/injection.dart`, bukan di sini — supaya `core`
tidak perlu tahu apa-apa soal package lain di workspace.

## Logger (`AppLogger`)

Wrapper tipis di atas [Talker](https://pub.dev/packages/talker_flutter)
supaya logging konsisten di seluruh app (pakai ini, bukan `print()`).
Panggil `AppLogger.init(verbose: ...)` sekali di bootstrap.

`AppLogger.error()`/`.critical()` bisa diteruskan ke sink eksternal
(mis. Sentry) lewat `AppLogger.registerErrorReporter((error, stackTrace)
{ ... })` — lihat pemakaiannya di `apps/main/lib/bootstrap.dart`. Dengan
begini `core` sendiri tetap tidak perlu bergantung pada Sentry atau
provider crash-reporting manapun; wiring-nya murni tanggung jawab app
layer.

## Testing

```bash
cd packages/core
flutter test test/unit
```

Mencakup `AppStringUtils`, `AppNumberUtils`, `AppDateUtils` (termasuk
kuirk `formatDuration` yang hanya menampilkan MM:SS — durasi di atas
1 jam "kehilangan" info jamnya, sesuai implementasi), serta perilaku
equality dan default value `Failure`/`AppException`.
