# core_l10n

Localization berbasis [slang](https://pub.dev/packages/slang) — type-safe,
tanpa perlu `BuildContext` kalau tidak mau. Menggantikan pendekatan ARB
bawaan Flutter (`flutter gen-l10n`) yang dipakai `apps/main` sebelumnya.

## Struktur

```
lib/
├── core_l10n.dart              # barrel export — export generated strings.g.dart
├── i18n/
│   ├── id.i18n.json             # sumber terjemahan Indonesia (base locale)
│   └── en.i18n.json             # sumber terjemahan Inggris
└── src/generated/                # HASIL GENERATE — jangan edit manual, di-gitignore
    ├── strings.g.dart
    ├── strings_id.g.dart
    └── strings_en.g.dart

slang.yaml                        # konfigurasi generator
```

## Menambah / mengubah terjemahan

1. Edit `lib/i18n/id.i18n.json` (base locale) **dan** `lib/i18n/en.i18n.json`
   — dua-duanya harus punya key yang sama persis, slang akan komplain
   kalau ada yang beda strukturnya.
2. Generate ulang:
   ```bash
   melos run gen:l10n
   # sama dengan: cd packages/core_l10n && dart run slang
   ```
3. Import hasilnya di package yang butuh (tambahkan
   `core_l10n: {path: ../../core_l10n}` ke `pubspec.yaml`-nya kalau
   belum ada).

JSON dikelompokkan per fitur/topik: `common`, `error`, `auth` (+
`auth.otp`), `assessment`, `profile`, `notification`, `dashboard`. Kalau
menambah string baru untuk fitur yang sudah ada kelompoknya, taruh di
situ; kalau untuk fitur baru, buat grup baru.

## Cara pakai di kode

Dua pola, pilih sesuai kebutuhan:

```dart
// Method A — tanpa BuildContext, tidak rebuild otomatis saat locale berubah
String label = t.auth.login;

// Method B — lewat BuildContext, widget rebuild otomatis saat locale berubah
String label = context.t.auth.login;
```

String dengan parameter jadi method, bukan getter:

```dart
context.t.auth.otp.subtitle(destination: '08xx'); // "Kode OTP telah dikirim ke 08xx"
context.t.assessment.pendingAnswers(count: 3);    // "3 jawaban menunggu sinkronisasi"
```

## Wiring di `apps/main`

`bootstrap.dart` memanggil `LocaleSettings.useDeviceLocale()` sebelum
`runApp`, dan `runApp` dibungkus `TranslationProvider`. `app.dart`
memakai `TranslationProvider.of(context).flutterLocale` dan
`AppLocaleUtils.supportedLocales` untuk `MaterialApp.router`. Locale
Inggris (`en`) di-*deferred load* (baru diunduh/dikompilasi saat
dibutuhkan) supaya tidak memperbesar bundle awal untuk locale non-default.

## Siapa yang sudah pakai ini

- `apps/main` — infrastruktur (`app.dart`, `bootstrap.dart`) dan
  placeholder home page.
- `feature_auth` — seluruh layar login/OTP (`login_page.dart`,
  `email_password_form.dart`, `otp_form.dart`).
- `feature_assessment` — layar intro, soal, dan selesai.

Kalau menambah fitur baru dengan UI, ikuti pola yang sama — jangan
hardcode string, cek dulu apakah key yang dibutuhkan sudah ada di
`common`/`error` sebelum menambah key baru.

## Testing

Tidak ada test khusus untuk package ini — isinya konfigurasi + kode
hasil generate. Kebenaran pemakaiannya tervalidasi lewat `dart analyze`
(key yang tidak ada akan gagal compile) dan widget test di package yang
memakainya (lihat `apps/main/test/widget_test.dart`).
