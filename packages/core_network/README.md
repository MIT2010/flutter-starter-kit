# core_network

HTTP client terpusat, keamanan runtime, WebSocket, dan sistem offline
queue. Ini package infrastruktur paling besar di workspace — hampir
semua fitur yang bicara ke backend lewat package ini.

## Struktur

```
lib/
├── core_network.dart                       # barrel export
└── src/
    ├── http/
    │   ├── api_client.dart                  # ApiClient — Dio wrapper
    │   └── interceptors/
    │       ├── auth_interceptor.dart        # attach token + auto-refresh saat 401
    │       ├── error_interceptor.dart       # DioException -> AppException
    │       └── logging_interceptor.dart     # log request/response (dev only)
    ├── models/
    │   ├── api_response.dart                # ApiResponse<T> — bentuk response ternormalisasi
    │   └── response_parser.dart             # normalisasi 4 variasi format backend
    ├── security/
    │   ├── security_interceptor.dart        # RASP (AppSecurityGuard) + blokir request
    │   ├── device_security_service.dart      # root/jailbreak/emulator/mock-location check
    │   └── certificate_pinning_interceptor.dart  # opsional, nonaktif secara default
    ├── websocket/
    │   └── reverb_manager.dart              # WebSocket client untuk Laravel Reverb
    ├── network_info.dart                     # cek status koneksi (online/offline)
    └── queue/
        ├── queue_handler.dart                # kontrak QueueHandler
        ├── retry_policy.dart                 # RetryPolicy.unlimited() / .limited()
        └── queue_sync_manager.dart           # orchestrator offline queue

test/unit/                                    # retry_policy_test, queue_sync_manager_test
```

## ApiClient

Dio instance dengan 4 interceptor terpasang berurutan:

1. **`SecurityInterceptor`** (opsional, aktif secara default) — cek
   `AppSecurityGuard.isSafe` (di-set dari RASP engine saat bootstrap) dan
   memblokir request kalau device dianggap tidak aman. Di-skip di web
   dan di development kecuali diaktifkan eksplisit.
2. **`AuthInterceptor`** — menempelkan `Authorization: Bearer <token>` ke
   setiap request. Kalau menerima 401 dan callback `refreshToken` di-set,
   otomatis coba refresh token sekali (dengan dedup — beberapa request
   yang gagal bersamaan cuma memicu satu refresh) lalu mengulang request
   yang gagal dengan token baru. Kalau refresh juga gagal, error diteruskan
   apa adanya.
3. **`ErrorInterceptor`** — mengubah `DioException` jadi `AppException`
   yang konsisten (`NetworkException`, `ServerException`,
   `UnauthorizedException`, `NotFoundException`, `ValidationException`).
4. **`LoggingInterceptor`** — log request/response, cuma jalan di
   development.

```dart
final apiClient = ApiClient(
  getAccessToken: () => sessionManager.getAccessToken(),
  refreshToken: () async { /* return true kalau berhasil refresh */ },
);

final response = await apiClient.get<Map<String, dynamic>>(
  '/some/endpoint',
  fromData: (json) => json as Map<String, dynamic>,
);
```

### ResponseParser

Backend kadang tidak konsisten soal bentuk response sukses/gagalnya.
`ResponseParser` menangani 4 variasi sekaligus, jadi kode di atasnya
selalu berurusan dengan `ApiResponse<T>` yang sama bentuknya:

```json
{"status": "ok"|"nok", "message": "...", "data": ...}
{"status": "ok"|"nok", "messages": [...], "data": ...}
{"status": true|false, "msg": "...", "data": ...}
{"result": "success"|"error", "message": "...", "data": ...}
```

## Keamanan

- **RASP** (`AppSecurityGuard`, via `flutter_secure_app`) — diinisialisasi
  sekali di bootstrap (`AppSecurityGuard.init()`), lalu `SecurityInterceptor`
  memblokir request kalau ada ancaman terdeteksi. Fail-open kalau init
  gagal (tidak memblokir app).
- **`DeviceSecurityService`** (via `safe_device`) — cek terpisah untuk
  jailbreak/root, emulator, dan mock location, hasilnya di-cache. Ini
  best-effort — tools seperti Magisk Hide bisa bypass deteksi, jangan
  jadikan satu-satunya lapisan keamanan.
- **`CertificatePinning`** — helper opsional, **sengaja tidak diaktifkan
  secara default**. Sertifikat Let's Encrypt (umum dipakai) rotasi tiap
  90 hari sehingga SHA-256 fingerprint berubah — aktifkan hanya kalau
  proyek kamu punya proses update fingerprint otomatis atau pakai SPKI
  pinning ke public key.

## WebSocket (`ReverbManager`)

Client untuk [Laravel Reverb](https://reverb.laravel.com/) (kompatibel
Pusher protocol), satu koneksi untuk banyak channel:

```dart
final reverb = ReverbManager(
  host: AppEnv.wsUrl, port: AppEnv.wsPort, appKey: AppEnv.wsAppKey,
  getAccessToken: () => sessionManager.getAccessToken(),
  authEndpoint: AppEnv.wsAuthEndpoint,
);
await reverb.connect();
final channel = await reverb.subscribePrivate('user.123');
reverb.on('user.123', 'NotificationSent').listen((event) { ... });
```

Private channel auth dikirim via header `Authorization: Bearer <token>`
ke `authEndpoint`, bukan lewat query param — token tidak bocor ke log
URL. Reconnect otomatis resubscribe semua channel yang tadinya aktif.

## Offline Queue

Sistem generik untuk operasi yang harus tetap terkirim meski koneksi
putus. Alurnya:

`QueueHandler` (kontrak, satu per tipe operasi, diimplementasikan oleh
fitur) → `QueueSyncManager` (orchestrator, satu instance per "jenis
antrian") → `QueueStorage` (persist ke Hive, lihat `core_storage`).

```dart
class MyHandler implements QueueHandler {
  @override
  String get type => 'my_operation';

  @override
  Future<bool> handle(QueueItem item) async {
    // return true = sukses (dihapus dari antrian)
    // return false = gagal, akan di-retry sesuai RetryPolicy
    // throw = error permanen, tidak masuk hitungan retry otomatis
  }
}

final manager = QueueSyncManager(
  storage: QueueStorage('queue_my_feature'),
  networkInfo: getIt<NetworkInfo>(),
  retryPolicy: const RetryPolicy.unlimited(), // atau .limited(maxAttempts: 5)
);
manager.registerHandler(MyHandler());
manager.startAutoSync(); // trigger otomatis saat konektivitas offline -> online
```

Detail penting:
- **Exponential backoff** — item yang gagal menunggu `2^attempt` detik
  (di-cap 60 detik) sebelum dicoba lagi, dihitung dari `lastAttemptAt`.
  Ada timer internal supaya item yang masih dalam jendela backoff tetap
  diproses ulang otomatis tanpa menunggu event konektivitas berikutnya.
- **Proses paralel** — semua item pending di-`Future.wait` bersamaan saat
  sync, bukan satu-satu.
- **`RetryPolicy.unlimited()`** dipakai untuk data yang tidak boleh hilang
  (contoh: jawaban assessment — lihat `feature_assessment`).
  **`RetryPolicy.limited(maxAttempts: N)`** untuk operasi non-kritis;
  item yang melebihi batas pindah ke status `failed` (bisa di-retry
  manual lewat `retryFailed(itemId)` atau dibuang lewat
  `discardFailed(itemId)`).

Contoh pemakaian nyata: `feature_assessment`'s
`AnswerSubmissionService` + `AnswerQueueHandler`.

## Testing

```bash
cd packages/core_network
flutter test test/unit
```

`retry_policy_test.dart` menguji kurva backoff dan `shouldRetry`.
`queue_sync_manager_test.dart` menguji seluruh siklus sync (item baru,
item dalam jendela backoff, retry sukses/gagal, auto-sync saat online)
dengan `QueueStorage`/`NetworkInfo`/`QueueHandler` di-mock (mockito).
