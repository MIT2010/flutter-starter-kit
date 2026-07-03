# Flutter Starter Kit

Monorepo Flutter dengan Clean Architecture, BLoC, dan code generation otomatis.

> Butuh gambaran arsitektur menyeluruh (bagaimana semua package saling
> terhubung, alur data end-to-end, keputusan desain)? Lihat
> [ARCHITECTURE.md](ARCHITECTURE.md).

## Quick Start

```bash
# 1. Clone repo
git clone <repo-url>
cd flutter_starter_kit

# 2. Install Melos, Mason, dan rename (sekali saja)
dart pub global activate melos
dart pub global activate mason_cli
dart pub global activate rename

# 3. Setup — install deps, rename project (opsional), generate semua file
melos run setup
# → config/{development,staging,production}.json otomatis dibuat dari
#   config/*.example.json kalau belum ada (edit isinya sesuai environment
#   kamu sendiri — file ini gitignored, aman diisi data asli).
# → Akan tanya: mau rename starter kit ini untuk project kamu sekarang?
#   Jawab "y" lalu isi org (com.tokokita) dan nama aplikasi (Toko Kita) —
#   apps/main langsung berganti identitas (Android/iOS/Web). Jawab "n"
#   atau Enter untuk skip, bisa dijalankan lagi kapan saja.
# → Folder android/ios/web yang hilang (mis. terhapus manual) otomatis
#   dipulihkan juga.

# 4. Jalankan aplikasi
melos run run:dev:web
```

Selesai. Tidak ada langkah lain.

---

## Perintah Sehari-hari

### Menjalankan App

```bash
melos run run:dev          # device default
melos run run:dev:android  # Android
melos run run:dev:ios      # iOS
melos run run:dev:web      # Chrome/PWA
melos run run:staging      # staging environment
```

### Build

```bash
melos run build:android:staging   # Android APK (staging)
melos run build:android:prod      # Android APK (production)
melos run build:ios:staging       # iOS IPA (staging)
melos run build:ios:prod          # iOS IPA (production)
melos run build:web:staging       # PWA (staging)
melos run build:web:prod          # PWA (production)
```

### Code Quality

```bash
melos run analyze        # static analysis
melos run format:fix     # auto-fix formatting
melos run lint           # analyze + format check
```

### Testing

```bash
melos run test           # jalankan semua unit test
melos run test:widget    # jalankan widget test
```

### Code Generation

```bash
melos run gen            # generate mock files (build_runner)
melos run gen:watch      # watch mode
melos run gen:l10n       # generate localization
```

### Feature & App Scaffolding

```bash
# Buat fitur baru (generate seluruh clean architecture)
melos run feature:new
# → Tanya nama fitur (snake_case) kalau tidak dikasih argumen
# → Output: packages/features/feature_<nama>/

# Generate unit test untuk fitur yang sudah ada
./tools/scripts/generate_test.sh <nama_fitur>
# Contoh:
./tools/scripts/generate_test.sh product
./tools/scripts/generate_test.sh assessment
# → Output: packages/features/feature_<nama>/test/unit/
# → Edit TODO sections sesuai entity dan use case
# → Jalankan: cd packages/features/feature_<nama> && dart run build_runner build

# Buat app BARU dalam satu monorepo — dipakai kalau satu produk memang
# butuh lebih dari satu aplikasi (mis. app tes mandiri + app khusus biro),
# BUKAN untuk starter kit yang berbeda produk (lihat ARCHITECTURE.md)
melos run app:new
# → Tanya org (menyarankan org yang sama dengan apps/main), nama aplikasi,
#   nama folder/package (snake_case)
# → Output: apps/<nama>/ — flutter create + skeleton starter kit
#   (core/core_network/core_storage/core_ui/core_l10n sudah terhubung),
#   otomatis terdaftar ke workspace + melos scripts run:<nama>:*/build:<nama>:*
```

---

## Environment

`melos run setup` otomatis membuat `config/{development,staging,production}.json`
dari `config/*.example.json` kalau belum ada. Ketiganya gitignored — JANGAN
pernah commit versi non-example (bisa berisi data sensitif). Kalau perlu
bikin ulang manual:

```bash
cp config/development.example.json config/development.json
cp config/staging.example.json     config/staging.json
cp config/production.example.json  config/production.json
```

Edit setiap file dengan nilai yang sesuai:

```json
{
  "ENV": "development",
  "APP_NAME": "Starter Kit Dev",
  "BASE_URL": "https://api-dev.example.com",
  "WS_URL": "wss://api-dev.example.com",
  "WS_PORT": "6001",
  "WS_APP_KEY": "your-pusher-app-key",
  "WS_AUTH_ENDPOINT": "https://api-dev.example.com/broadcasting/auth",
  "SENTRY_DSN": "",
  "ENABLE_LOGS": "true",
  "ENABLE_DEVTOOLS": "true"
}
```

`SENTRY_DSN` mengaktifkan crash reporting (Sentry) kalau diisi — kosongkan untuk development, error tetap tercatat lokal lewat `AppLogger`.

---

## Struktur Project

```
flutter_starter_kit/
├── apps/main/              # Entry point — Android, iOS, PWA
│   ├── lib/
│   │   ├── main.dart               # dev entry point
│   │   ├── main_staging.dart       # staging entry point
│   │   ├── main_production.dart    # production entry point
│   │   ├── bootstrap.dart          # app initialization
│   │   ├── app.dart                # MaterialApp setup
│   │   └── core/
│   │       ├── di/                 # dependency injection
│   │       ├── router/             # go_router + auth guard
│   │       └── observer/           # BLoC observer
│   └── test/
│       └── widget/                 # widget test
│
├── config/                 # Environment config per flavor
│   ├── development.json            # ⚠️ tidak di-commit
│   ├── staging.json                # ⚠️ tidak di-commit
│   ├── production.json             # ⚠️ tidak di-commit
│   ├── development.example.json    # ✅ template, di-commit
│   ├── staging.example.json        # ✅ template, di-commit
│   └── production.example.json     # ✅ template, di-commit
│
├── packages/
│   ├── core/               # Error, env, logger, DI, utils
│   ├── core_network/       # ApiClient, interceptors, offline-queue orchestrator, ReverbManager
│   ├── core_storage/       # HiveStorage, SecureStorage, primitif queue
│   ├── core_ui/            # Design system — tokens, theme, components
│   ├── core_l10n/          # Localization (slang) — id/en, dipakai feature_auth & feature_assessment
│   ├── shared/
│   │   ├── shared_auth/        # UserEntity, SessionManager contract
│   │   └── shared_assessment/  # Assessment entities (sealed class)
│   └── features/
│       ├── feature_auth/         # ✅ Login, OTP, session (lengkap)
│       ├── feature_assessment/   # ✅ Intro, soal (4 tipe), submit, resume offline (lengkap)
│       ├── feature_dashboard/    # 🔲 Skeleton
│       ├── feature_profile/      # 🔲 Skeleton
│       └── feature_notification/ # 🔲 Skeleton
│
└── tools/
    ├── mason/
    │   └── bricks/
    │       ├── feature_brick/  # Generate struktur feature baru
    │       ├── test_brick/     # Generate unit test scaffold
    │       └── app_brick/      # Generate struktur app baru (satu monorepo)
    └── scripts/
        ├── generate_test.sh    # Wrapper untuk test_brick
        ├── generate_feature.sh # Wrapper untuk feature_brick
        ├── rename_project.dart # Rename apps/main (dipanggil dari `melos run setup`)
        ├── create_app.dart     # Orkestrasi `melos run app:new`
        └── rename_helper.dart  # Logic bersama rename_project.dart + create_app.dart
```

---

## Menambah Feature Baru

```bash
# Step 1 — Generate scaffold
melos run feature:new
# Masukkan nama fitur saat diminta: product

# Step 2 — Daftarkan ke workspace root pubspec.yaml
# Tambahkan: - packages/features/feature_product

# Step 3 — Daftarkan ke apps/main/pubspec.yaml
# Tambahkan di dependencies:
#   feature_product:
#     path: ../../packages/features/feature_product

# Step 4 — Implementasi data layer
# Edit: lib/src/data/models/, datasources/, repositories/

# Step 5 — Register DI
# Edit: apps/main/lib/core/di/injection.dart

# Step 6 — Tambahkan route
# Edit: apps/main/lib/core/router/app_router.dart

# Step 7 — Generate code
melos run gen

# Step 8 — Generate test scaffold
./tools/scripts/generate_test.sh product
# Edit TODO sections, lalu:
cd packages/features/feature_product
dart run build_runner build
flutter test test/unit/
```

---

## License

[MIT](LICENSE) — bebas dipakai, dimodifikasi, dan didistribusikan ulang, termasuk untuk proyek komersial.
