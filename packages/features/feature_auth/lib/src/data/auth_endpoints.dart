/// Konfigurasi endpoint auth.
/// Ubah nilai ini sesuai dengan backend project kamu.
/// Tidak perlu menyentuh logic apapun — hanya file ini.
abstract class AuthEndpoints {
  AuthEndpoints._();

  static const login = '/auth/login';
  static const requestOtp = '/auth/otp/request';
  static const verifyOtp = '/auth/otp/verify';
  static const logout = '/auth/logout';
  static const refresh = '/auth/refresh';
  static const me = '/auth/me';
}
