# Flutter Starter Kit

Monorepo Flutter dengan Clean Architecture, BLoC, dan code generation otomatis.

## Quick Start

```bash
# 1. Clone repo
git clone <repo-url>
cd flutter_starter_kit

# 2. Install Melos (sekali saja)
dart pub global activate melos

# 3. Setup — install deps + generate semua file
melos run setup

# 4. Jalankan aplikasi
cd apps/main
flutter run --target lib/main.dart
```

Selesai. Tidak ada langkah lain.

## Perintah Sehari-hari

```bash
# Analisis dan format
melos run analyze
melos run format:fix

# Test
melos run test
melos run test:unit

# Generate ulang setelah ubah model/mock
melos run gen

# Buat fitur baru
melos run feature:new

# Build app
cd apps/main
flutter build apk --target lib/main_staging.dart \
  --dart-define=ENV=staging \
  --dart-define=BASE_URL=https://api.example.com \
  --dart-define=WS_URL=wss://api.example.com
```

## Struktur Project
flutter_starter_kit/

├── apps/main/              # Entry point — Android, iOS, PWA

├── packages/

│   ├── core/               # Error, env, logger, DI, utils

│   ├── core_network/       # ApiClient, ResponseParser, ReverbManager

│   ├── core_storage/       # HiveStorage, SecureStorage

│   ├── core_ui/            # Design system — tokens, theme, components

│   ├── shared/

│   │   ├── shared_auth/        # UserEntity, SessionManager

│   │   └── shared_assessment/  # Entity assessment (sealed class)

│   └── features/

│       ├── feature_auth/         # Login, OTP, session

│       ├── feature_assessment/   # Pengerjaan tes psikologi

│       ├── feature_dashboard/    # Dashboard

│       ├── feature_profile/      # Profil user

│       └── feature_notification/ # Notifikasi

└── tools/mason/            # Feature brick generator
## Environment Variables

```bash
--dart-define=ENV=development|staging|production
--dart-define=BASE_URL=https://api.example.com
--dart-define=WS_URL=wss://api.example.com
```
