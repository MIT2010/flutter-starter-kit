import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';

const _appBoxName = 'app_box';

/// Opens (and, on first launch, initializes) the single shared Hive box for
/// this app. Registered via [preResolve] so [HiveClient] can depend on an
/// already-open [Box] rather than every call site awaiting init itself.
@module
abstract class StorageModule {
  @preResolve
  Future<Box<dynamic>> get appBox async {
    await Hive.initFlutter();
    return Hive.openBox<dynamic>(_appBoxName);
  }
}

/// Thin wrapper around the shared Hive box.
///
/// This is the only class in the app that should talk to Hive directly —
/// everything else (interceptors, repositories) goes through this so the
/// storage engine can be swapped later without touching call sites.
@lazySingleton
class HiveClient {
  HiveClient(this._box);

  final Box<dynamic> _box;

  static const authTokenKey = 'auth_token';

  T? read<T>(String key) => _box.get(key) as T?;

  Future<void> write(String key, dynamic value) => _box.put(key, value);

  Future<void> delete(String key) => _box.delete(key);

  String? get authToken => read<String>(authTokenKey);

  Future<void> setAuthToken(String token) => write(authTokenKey, token);

  Future<void> clearAuthToken() => delete(authTokenKey);
}
