# shared_auth

Entity dan kontrak auth yang dipakai lintas fitur, tanpa membawa
implementasinya. Fitur lain (mis. `feature_assessment`, atau fitur baru
yang butuh tahu status login) bergantung ke package ini, **bukan** ke
`feature_auth` langsung — itu tujuan utama package ini ada.

## Struktur

```
lib/
├── shared_auth.dart                # barrel export
└── src/
    ├── entities/
    │   ├── user_entity.dart         # UserEntity — id, name, email, avatarUrl, phoneNumber, role
    │   └── auth_token_entity.dart   # AuthTokenEntity — accessToken, refreshToken, expiresAt
    └── contracts/
        ├── auth_status.dart         # enum AuthStatus — checking / authenticated / unauthenticated
        └── session_manager.dart     # abstract class SessionManager
```

## `SessionManager` — dependency inversion

Ini kontrak paling penting di package ini. `shared_auth` mendefinisikan
`abstract class SessionManager`, dan `feature_auth`
(`SessionManagerImpl`) yang mengimplementasikannya. Fitur lain — dan
`core_network`'s `ApiClient`/`ReverbManager` — cukup bergantung pada
kontrak abstrak ini lewat callback (`getAccessToken`, `getRefreshToken`),
tidak perlu tahu `feature_auth` ada.

```dart
abstract class SessionManager {
  Stream<AuthStatus> get authStatusStream;
  AuthStatus get currentStatus;
  UserEntity? get currentUser;

  Future<void> saveSession({required AuthTokenEntity token, required UserEntity user});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearSession();
  Future<bool> isLoggedIn();
}
```

Kalau menambah fitur baru yang perlu tahu "apakah user sedang login"
atau "siapa user yang login", import `shared_auth` dan minta
`SessionManager` (atau `UserEntity`) lewat constructor — jangan import
`feature_auth`.

## Entity

- **`UserEntity`** — data user yang sudah login. Ada getter `initials`
  (untuk avatar placeholder dari nama).
- **`AuthTokenEntity`** — pasangan access/refresh token + `expiresAt`,
  dengan getter `isExpired` dan `timeUntilExpiry`.

Keduanya `extends Equatable`, immutable.

## Testing

Package ini murni entity + kontrak abstrak, tidak ada logic untuk
diuji langsung — perilakunya diuji lewat implementasinya
(`feature_auth`'s `test/unit/auth_bloc_test.dart` dkk).
