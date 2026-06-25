import '../entities/auth_token_entity.dart';
import '../entities/user_entity.dart';
import 'auth_status.dart';

/// Kontrak untuk manajemen sesi — didefinisikan di shared_auth,
/// diimplementasikan oleh feature_auth.
///
/// Fitur lain (feature_order, feature_chat, dst) hanya
/// berinteraksi dengan interface ini, tidak dengan feature_auth langsung.
abstract class SessionManager {
  /// Stream status autentikasi — fitur bisa listen untuk update UI
  Stream<AuthStatus> get authStatusStream;

  /// Status autentikasi saat ini
  AuthStatus get currentStatus;

  /// Data user yang sedang login — null jika belum login
  UserEntity? get currentUser;

  /// Simpan session setelah login berhasil
  Future<void> saveSession({
    required AuthTokenEntity token,
    required UserEntity user,
  });

  /// Ambil access token — dipakai oleh ApiClient dan ReverbManager
  Future<String?> getAccessToken();

  /// Ambil refresh token — dipakai saat token expired
  Future<String?> getRefreshToken();

  /// Hapus semua data session — dipanggil saat logout
  Future<void> clearSession();

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn();
}
