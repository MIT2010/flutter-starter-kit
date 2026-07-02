import 'package:core_storage/core_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Fake platform implementation — menghindari perlu Keystore/Keychain asli
/// saat test. Mengikuti pola resmi federated plugin (MockPlatformInterfaceMixin)
/// yang direkomendasikan flutter_secure_storage sendiri untuk testing.
class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform
    with MockPlatformInterfaceMixin {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _data[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _data[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _data.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map.of(_data);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _data.clear();
  }
}

void main() {
  late SecureStorage secureStorage;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    secureStorage = SecureStorage();
  });

  test('write dan read mengembalikan value yang sama', () async {
    await secureStorage.write(key: 'token', value: 'abc123');
    expect(await secureStorage.read(key: 'token'), 'abc123');
  });

  test('read mengembalikan null untuk key yang tidak ada', () async {
    expect(await secureStorage.read(key: 'tidak-ada'), isNull);
  });

  test('containsKey membedakan key yang ada dan tidak', () async {
    await secureStorage.write(key: 'token', value: 'abc123');
    expect(await secureStorage.containsKey(key: 'token'), true);
    expect(await secureStorage.containsKey(key: 'lainnya'), false);
  });

  test('delete menghapus key tertentu saja', () async {
    await secureStorage.write(key: 'a', value: '1');
    await secureStorage.write(key: 'b', value: '2');
    await secureStorage.delete(key: 'a');

    expect(await secureStorage.read(key: 'a'), isNull);
    expect(await secureStorage.read(key: 'b'), '2');
  });

  test('deleteAll menghapus semua key', () async {
    await secureStorage.write(key: 'a', value: '1');
    await secureStorage.write(key: 'b', value: '2');
    await secureStorage.deleteAll();

    expect(await secureStorage.containsKey(key: 'a'), false);
    expect(await secureStorage.containsKey(key: 'b'), false);
  });
}
