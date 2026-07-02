# core_ui

Design system aplikasi: token warna/spacing/tipografi, tema Material 3,
dan koleksi widget siap pakai. Tidak ada logic bisnis di sini — murni
presentasi.

## Struktur

```
lib/
├── core_ui.dart                 # barrel export
└── src/
    ├── tokens/
    │   ├── app_colors.dart       # semua warna — jangan pakai Color(0x...) langsung di widget
    │   ├── app_spacing.dart      # skala spacing, radius, tinggi komponen
    │   └── app_typography.dart   # skala teks (Google Fonts: Inter)
    ├── theme/
    │   └── app_theme.dart        # AppTheme.light / AppTheme.dark (Material 3)
    ├── components/                # murni visual, tanpa behavior
    │   ├── app_text.dart
    │   ├── app_badge.dart
    │   ├── app_card.dart
    │   └── app_divider.dart
    └── patterns/                  # ada behavior/state
        ├── app_button.dart
        ├── app_text_field.dart
        ├── app_loading.dart
        ├── app_error_view.dart
        └── app_empty_view.dart
```

`components/` vs `patterns/` sengaja dipisah: **components** murni
visual (terima data, render, selesai — beberapa bahkan tidak perlu
`BuildContext` untuk styling-nya, seperti `AppText`), sementara
**patterns** mengurus behavior/state sederhana (loading, error, empty
state, form input).

## Token

- **`AppColors`** — brand (primary/secondary), semantic
  (success/warning/error/info), neutral scale (50–900), surface, text,
  border, plus warna khusus fitur assessment
  (`assessmentCorrect`/`assessmentTimer`/dst). Ganti brand color di sini
  untuk rebranding, jangan cari-cari `Color(0xFF...)` di seluruh kode.
- **`AppSpacing`** — skala spacing (`xs`–`xxxl`), border radius
  (`radiusXs`–`radiusFull`), ukuran icon, tinggi button/input/app
  bar/bottom nav, `screenPadding`.
- **`AppTypography`** — skala teks (Display, Heading, Body, Label,
  Caption, Button) berbasis font Inter (Google Fonts).

## Tema

`AppTheme.light` dan `AppTheme.dark` — `ThemeData` Material 3 lengkap
(app bar, button, input, card, divider, bottom nav, chip) dibangun dari
token di atas. Dipasang di `apps/main/lib/app.dart` lewat
`MaterialApp.router(theme: AppTheme.light, darkTheme: AppTheme.dark,
themeMode: ThemeMode.system)`.

## Komponen & Pattern

Semua widget pakai named constructor yang jelas namanya:

```dart
AppText.headingLg('Judul');
AppText.bodyMd('Isi teks', color: AppColors.textSecondary);

AppButton(label: 'Simpan', onPressed: _onSave, variant: AppButtonVariant.primary);
AppTextField(label: 'Email', controller: _emailController, validator: ...);

AppLoading.fullScreen(message: 'Memuat...');
AppErrorView(message: failure.message, onRetry: _onRetry);
AppEmptyView(message: 'Belum ada data');

AppCard(child: ...); // otomatis sesuaikan warna dark/light mode
AppBadge.success('Aktif');
```

Lihat pemakaian nyata di `feature_auth` (`login_page.dart`,
`email_password_form.dart`, `otp_form.dart`) dan `feature_assessment`
(halaman intro/soal/selesai) untuk pola komposisi yang konsisten.

## Testing

Belum ada widget test khusus untuk `core_ui` — kalau menambah komponen
baru dengan logic non-trivial (bukan sekadar styling), tambahkan test
di `test/` mengikuti pola paket lain di workspace ini.
