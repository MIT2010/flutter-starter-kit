# feature_notification

**Status: 🔲 Skeleton — belum diimplementasikan.** Hanya berisi barrel
file kosong (`lib/feature_notification.dart`) dan `pubspec.yaml` dengan
dependency dasar (`core`, `core_network`, `core_ui`, `shared_auth`,
`flutter_bloc`, `fpdart`, `equatable`) yang sudah disiapkan.

## Rencana

Sesuai deskripsi di `pubspec.yaml`: "Notification — notifikasi in-app
dan push". `core_l10n` sudah punya key dasar (`notification.title`,
`notification.empty`, `notification.markAllRead`).

**Catatan penting:** belum ada package push notification (Firebase
Cloud Messaging, OneSignal, dll) di workspace ini sama sekali. Ini
keputusan yang sengaja diserahkan ke kamu — pilihan provider biasanya
terikat ke infrastruktur backend (APNs certificate, FCM sender ID,
dll) yang starter kit ini tidak bisa asumsikan. Untuk notifikasi
**in-app** saja (tanpa push), `core_network`'s `ReverbManager`
(WebSocket) sudah bisa dipakai langsung — lihat README `core_network`.

## Cara mulai mengisi

1. Untuk notifikasi in-app real-time: pakai `ReverbManager.subscribePrivate()`
   + `.on(channel, event)` (lihat README `core_network`), simpan hasilnya
   sebagai state di BLoC fitur ini.
2. Untuk push notification: tambahkan package pilihanmu (mis.
   `firebase_messaging`) ke `pubspec.yaml`, setup native config
   (Android/iOS) sesuai dokumentasi provider tsb, lalu inisialisasi di
   `apps/main/lib/bootstrap.dart`.
3. Ikuti pola clean architecture yang sama seperti `feature_auth`/
   `feature_assessment` untuk bagian data/domain/presentation-nya:

```bash
melos run feature:new
./tools/scripts/generate_test.sh notification
```

Jangan lupa daftarkan ke `apps/main`'s `injection.dart` dan
`app_router.dart` begitu ada implementasi nyata.
