import 'package:core_storage/core_storage.dart';

/// Keys untuk SecureStorage
abstract class _AuthStorageKeys {
  static const accessToken = 'auth_access_token';
  static const refreshToken = 'auth_refresh_token';
  static const tokenExpiresAt = 'auth_token_expires_at';
}

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<DateTime?> getTokenExpiresAt();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _secureStorage.write(
        key: _AuthStorageKeys.accessToken,
        value: accessToken,
      ),
      _secureStorage.write(
        key: _AuthStorageKeys.refreshToken,
        value: refreshToken,
      ),
      _secureStorage.write(
        key: _AuthStorageKeys.tokenExpiresAt,
        value: expiresAt.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.read(key: _AuthStorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: _AuthStorageKeys.refreshToken);
  }

  @override
  Future<DateTime?> getTokenExpiresAt() async {
    final raw = await _secureStorage.read(key: _AuthStorageKeys.tokenExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      _secureStorage.delete(key: _AuthStorageKeys.accessToken),
      _secureStorage.delete(key: _AuthStorageKeys.refreshToken),
      _secureStorage.delete(key: _AuthStorageKeys.tokenExpiresAt),
    ]);
  }
}
