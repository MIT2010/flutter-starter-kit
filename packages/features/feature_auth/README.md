# feature_auth

Fitur autentikasi lengkap — login, OTP, session, refresh token. Ini
package **paling matang** di workspace dan jadi acuan pola Clean
Architecture + BLoC untuk fitur lain (lihat juga `feature_assessment`
sebagai contoh kedua).

## Dua pola login

- **Pola A — OTP saja**: user masukkan nomor HP/email →
  `AuthRequestOtpEvent` → verifikasi OTP. Dipakai kalau
  `LoginPage(useOtpOnly: true)`.
- **Pola B — Email + password** (default): user masukkan
  email+password → `AuthLoginWithEmailPasswordEvent` → backend
  trigger OTP → verifikasi OTP. Kedua pola konvergen di
  `AuthVerifyOtpEvent`.

## Struktur

```
lib/
├── feature_auth.dart                          # barrel export
└── src/
    ├── data/
    │   ├── auth_endpoints.dart                  # daftar endpoint — ubah sesuai backend kamu
    │   ├── datasources/
    │   │   ├── auth_remote_datasource.dart       # panggil ApiClient
    │   │   └── auth_local_datasource.dart        # baca/tulis token via SecureStorage
    │   ├── models/                               # AuthTokenModel, OtpModel, UserModel — fromJson/toEntity
    │   └── repositories/
    │       └── auth_repository_impl.dart         # AppException -> Failure
    ├── domain/
    │   ├── entities/otp_entity.dart
    │   ├── repositories/auth_repository.dart      # kontrak abstrak
    │   └── usecases/
    │       ├── login_with_email_password_usecase.dart
    │       ├── request_otp_usecase.dart
    │       ├── verify_otp_usecase.dart
    │       ├── logout_usecase.dart
    │       ├── get_current_user_usecase.dart
    │       └── refresh_token_usecase.dart         # dipakai ApiClient untuk auto-refresh saat 401
    ├── session/
    │   └── session_manager_impl.dart              # implementasi shared_auth.SessionManager
    └── presentation/
        ├── bloc/
        │   ├── auth_bloc.dart
        │   ├── auth_event.dart                    # part of auth_bloc.dart
        │   └── auth_state.dart                    # part of auth_bloc.dart
        ├── pages/login_page.dart
        └── widgets/
            ├── email_password_form.dart
            └── otp_form.dart

test/unit/          # auth_bloc_test, login_usecase_test, verify_otp_usecase_test (17 test)
```

## `AuthBloc`

| Event | Efek |
|---|---|
| `AuthCheckStatusEvent` | Dipanggil sekali saat app dibuka (lihat `AppRouter`). Cek token tersimpan lewat `SessionManager`, kalau ada & valid ambil `GetCurrentUserUseCase`. |
| `AuthLoginWithEmailPasswordEvent` | Pola B — kirim email+password, backend trigger OTP. |
| `AuthRequestOtpEvent` | Pola A — minta OTP langsung ke nomor/email. |
| `AuthVerifyOtpEvent` | Verifikasi kode OTP (dipakai kedua pola) → sukses berarti `SessionManager.saveSession()` lalu `AuthAuthenticated`. |
| `AuthLogoutEvent` | `LogoutUseCase()` + `SessionManager.clearSession()`. |

State: `AuthChecking`, `AuthLoading`, `AuthOtpSent(otp)`,
`AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError(message)`.

`LoginPage` cukup satu `switch` atas state ini untuk memutuskan render
apa (`AppLoading`, `OtpForm`, atau `EmailPasswordForm`/OTP-only form).
Auth guard-nya sendiri (redirect ke `/home` saat authenticated, ke
`/login` saat tidak) ada di `apps/main/lib/core/router/app_router.dart`,
bukan di package ini.

## Refresh token otomatis

`RefreshTokenUseCase` tidak dipanggil manual dari UI — dia dipasang
sebagai callback `refreshToken` saat `ApiClient` dibuat (lihat
`apps/main/lib/core/di/injection.dart`). Begitu ada request yang gagal
401, `ApiClient`'s `AuthInterceptor` otomatis panggil use case ini,
simpan token baru, lalu mengulang request yang tadi gagal — transparan
buat kode yang manggil API, termasuk `feature_assessment`.

## Localization

Semua string di `login_page.dart`, `email_password_form.dart`,
`otp_form.dart` sudah lewat `core_l10n` (`context.t.auth.*`) — lihat
README `core_l10n` untuk cara menambah/mengubah teksnya. Jangan
hardcode string baru di sini.

## Testing

```bash
cd packages/features/feature_auth
dart run build_runner build   # generate ulang mocks (*.mocks.dart, gitignored)
flutter test test/unit
```

- `auth_bloc_test.dart` — `bloc_test`, semua event di atas + kasus
  gagal (kredensial salah, OTP salah).
- `login_usecase_test.dart` / `verify_otp_usecase_test.dart` — validasi
  input (email/password/kode kosong, panjang kode) dan delegasi ke
  repository.

Mocks di-generate via `mockito` + `build_runner`, hasilnya
(`*.mocks.dart`) sengaja **tidak** di-commit (lihat `.gitignore`) —
generate ulang tiap kali `dart pub get`/setelah clone.
