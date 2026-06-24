import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage untuk data sensitif — token, kredensial, data enkripsi.
///
/// Di Android: menggunakan Android Keystore
/// Di iOS: menggunakan Keychain
/// Di Web: menggunakan encrypted localStorage
class SecureStorage {
  SecureStorage()
      : _storage = const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key: key);
  }
}
