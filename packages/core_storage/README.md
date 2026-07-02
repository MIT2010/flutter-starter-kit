# core_storage

Semua penyimpanan lokal ada di sini: cache non-sensitif (Hive CE) dan
data sensitif (Keystore/Keychain via `flutter_secure_storage`). Package
generik ini juga jadi rumah untuk `QueueItem`/`QueueStorage` yang
dipakai sistem offline queue-nya `core_network`.

## Struktur

```
lib/
├── core_storage.dart          # barrel export
└── src/
    ├── app_storage.dart        # AppStorage.init() — panggil sekali di bootstrap
    ├── hive_storage.dart        # HiveStorage<T> — cache generik key-value
    ├── secure_storage.dart      # SecureStorage — token & data sensitif
    └── queue/
        ├── queue_item.dart      # model QueueItem + QueueItemStatus
        └── queue_storage.dart   # QueueStorage — persist QueueItem ke Hive

test/unit/                       # hive_storage_test, queue_storage_test, secure_storage_test
```

## `HiveStorage<T>`

Wrapper generik di atas satu Hive box, untuk cache yang **tidak
sensitif**. Satu instance = satu box (dipisah lewat nama):

```dart
final storage = HiveStorage<String>('user_cache');
await storage.put('name', 'Budi');
final name = await storage.get('name'); // 'Budi'
```

Method: `put`, `get`, `delete`, `clear`, `containsKey`, `getAll`. Untuk
tipe data kompleks (bukan `String`/primitif), encode dulu ke JSON string
sebelum `put` — lihat pola yang dipakai `QueueStorage` dan
`feature_assessment`'s `AssessmentLocalDataSource`.

`AppStorage.init()` (panggil sekali di `bootstrap()`) yang menyiapkan
Hive lewat `Hive.initFlutter()` sebelum `HiveStorage` mana pun dipakai.

## `SecureStorage`

Untuk token, kredensial, dan data sensitif lain. Android pakai Keystore,
iOS pakai Keychain (`KeychainAccessibility.first_unlock`), Web pakai
encrypted localStorage — semua otomatis lewat `flutter_secure_storage`.

```dart
final secureStorage = SecureStorage();
await secureStorage.write(key: 'access_token', value: token);
final token = await secureStorage.read(key: 'access_token');
```

Method: `write`, `read`, `delete`, `deleteAll`, `containsKey`. Dipakai
`feature_auth`'s `AuthLocalDataSource` untuk simpan access/refresh
token — **jangan pernah simpan token di `HiveStorage`**.

## `QueueItem` & `QueueStorage`

`QueueItem` adalah model generik untuk satu item dalam offline queue
(`id`, `type`, `data` sebagai JSON bebas, `status`, `retryCount`,
`lastAttemptAt`, `lastError`) — lihat dokumentasi lengkap sistem
antrian di README `core_network`. `QueueStorage` mem-persist list
`QueueItem` sebagai JSON-encoded string ke satu Hive box (satu box per
"jenis antrian", supaya tidak tercampur — lihat cara pakainya di
`apps/main`'s `injection.dart`, ada `queue_assessment_answers` dan
`queue_generic_mutations`).

`getAll()`/`getByStatus()` selalu mengurutkan berdasarkan `createdAt`
(FIFO). `save()` dengan `id` yang sudah ada akan menimpa item lama
(upsert), bukan menambah duplikat.

## Testing

```bash
cd packages/core_storage
flutter test test/unit
```

`hive_storage_test.dart` dan `queue_storage_test.dart` jalan dengan Hive
sungguhan (`Hive.init()` ke direktori temp), bukan mock — supaya
perilaku asli (sorting, upsert, filter status) benar-benar teruji.
`secure_storage_test.dart` mem-fake `FlutterSecureStoragePlatform` lewat
`MockPlatformInterfaceMixin` (pola resmi yang direkomendasikan
`flutter_secure_storage`), tanpa perlu Keystore/Keychain asli.
