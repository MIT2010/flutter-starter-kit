# feature_dashboard

**Status: 🔲 Skeleton — belum diimplementasikan.** Hanya berisi barrel
file kosong (`lib/feature_dashboard.dart`) dan `pubspec.yaml` dengan
dependency dasar (`core`, `core_network`, `core_ui`, `shared_auth`,
`shared_assessment`, `flutter_bloc`, `fpdart`, `equatable`) yang sudah
di-siapkan.

## Rencana

Sesuai deskripsi di `pubspec.yaml`: "Dashboard — ringkasan dan history".
Dependency ke `shared_assessment` sudah ditambahkan lebih dulu karena
dashboard kemungkinan akan menampilkan ringkasan/riwayat hasil tes
(`AssessmentSessionEntity`, dll) — sesuaikan lagi kalau kebutuhannya
berubah.

## Cara mulai mengisi

Jangan mulai dari nol — ikuti pola yang sudah terbukti di dua fitur
lengkap di workspace ini:

1. **`feature_auth`** — pola paling sederhana untuk dipelajari
   (data/domain/presentation, BLoC, testing).
2. **`feature_assessment`** — pola kedua, termasuk contoh integrasi
   dengan sistem offline queue dan cache lokal (`HiveStorage`) kalau
   dashboard butuh cache/resume juga.

Langkah konkret (lihat `README.md` di root untuk detail lengkap):

```bash
# Scaffold clean architecture dasar (opsional, bisa juga dari feature_auth sbg referensi)
melos run feature:new

# Setelah ada implementasi, generate test scaffold
./tools/scripts/generate_test.sh dashboard
```

Jangan lupa: daftarkan dependency baru ke `apps/main`'s `injection.dart`
(DI) dan `app_router.dart` (route) begitu ada halaman untuk dirender —
lihat bagaimana `feature_assessment` melakukannya sebagai contoh.
