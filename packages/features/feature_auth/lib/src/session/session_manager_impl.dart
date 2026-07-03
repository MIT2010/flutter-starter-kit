import 'dart:async';
import 'package:core/core.dart';
import 'package:shared_auth/shared_auth.dart';
import '../data/datasources/auth_local_datasource.dart';

/// Implementasi SessionManager dari shared_auth.
/// Ini adalah satu-satunya class yang tahu tentang
/// status auth di seluruh aplikasi.
class SessionManagerImpl implements SessionManager {
  SessionManagerImpl({required AuthLocalDataSource localDataSource})
    : _local = localDataSource;

  final AuthLocalDataSource _local;

  final _statusController = StreamController<AuthStatus>.broadcast();

  AuthStatus _currentStatus = AuthStatus.checking;
  UserEntity? _currentUser;

  @override
  Stream<AuthStatus> get authStatusStream => _statusController.stream;

  @override
  AuthStatus get currentStatus => _currentStatus;

  @override
  UserEntity? get currentUser => _currentUser;

  void _updateStatus(AuthStatus status) {
    _currentStatus = status;
    _statusController.add(status);
    AppLogger.debug('[Session] Status → $status');
  }

  @override
  Future<void> saveSession({
    required AuthTokenEntity token,
    required UserEntity user,
  }) async {
    await _local.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
    );
    _currentUser = user;
    _updateStatus(AuthStatus.authenticated);
  }

  @override
  Future<String?> getAccessToken() {
    return _local.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() {
    return _local.getRefreshToken();
  }

  @override
  Future<void> clearSession() async {
    await _local.clearAll();
    _currentUser = null;
    _updateStatus(AuthStatus.unauthenticated);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _local.getAccessToken();
    if (token == null) return false;

    final expiresAt = await _local.getTokenExpiresAt();
    if (expiresAt == null) return false;

    return DateTime.now().isBefore(expiresAt);
  }

  /// Inisialisasi status saat app pertama kali dibuka
  Future<void> initialize() async {
    _updateStatus(AuthStatus.checking);
    final loggedIn = await isLoggedIn();
    _updateStatus(
      loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  void dispose() {
    _statusController.close();
  }
}
