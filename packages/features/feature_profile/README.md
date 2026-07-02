# feature_profile

**Status: 🔲 Skeleton — belum diimplementasikan.** Hanya berisi barrel
file kosong (`lib/feature_profile.dart`) dan `pubspec.yaml` dengan
dependency dasar (`core`, `core_network`, `core_ui`, `shared_auth`,
`flutter_bloc`, `fpdart`, `equatable`) yang sudah disiapkan.

## Rencana

Sesuai deskripsi di `pubspec.yaml`: "Profile — data dan edit profil
user". Dependency ke `shared_auth` sudah ada karena data profil pasti
berbasis `UserEntity` yang sama dengan yang dipakai `feature_auth`.

`core_l10n` sudah punya key siap pakai untuk fitur ini
(`profile.title`, `profile.editProfile`, `profile.name`,
`profile.phone`, `profile.saveChanges`) — tinggal dipakai lewat
`context.t.profile.*`, tidak perlu menambah key baru untuk kasus dasar.

## Cara mulai mengisi

Ikuti pola yang sudah terbukti di `feature_auth` dan
`feature_assessment` (lihat README masing-masing untuk detail struktur
data/domain/presentation + testing):

```bash
melos run feature:new
./tools/scripts/generate_test.sh profile
```

Kemungkinan besar butuh use case baru di `feature_auth` juga (mis.
`UpdateProfileUseCase`) kalau edit profil memanggil endpoint auth yang
sama — pertimbangkan apakah logic itu sebaiknya tinggal di sini atau
di `feature_auth`, tergantung siapa pemilik data sebenarnya di backend
kamu.

Jangan lupa daftarkan ke `apps/main`'s `injection.dart` dan
`app_router.dart` begitu ada implementasi nyata.
