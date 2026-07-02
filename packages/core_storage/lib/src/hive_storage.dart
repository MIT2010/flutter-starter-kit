import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Generic key-value storage berbasis Hive CE.
/// Digunakan untuk cache data yang tidak sensitif.
///
/// Contoh penggunaan:
///   final storage = `HiveStorage<String>`('user_cache');
///   await storage.put('name', 'Budi');
///   final name = await storage.get('name');
class HiveStorage<T> {
  HiveStorage(this._boxName);

  final String _boxName;
  Box<T>? _box;

  Future<Box<T>> get _openBox async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<T>(_boxName);
    return _box!;
  }

  Future<void> put(String key, T value) async {
    final box = await _openBox;
    await box.put(key, value);
  }

  Future<T?> get(String key) async {
    final box = await _openBox;
    return box.get(key);
  }

  Future<void> delete(String key) async {
    final box = await _openBox;
    await box.delete(key);
  }

  Future<void> clear() async {
    final box = await _openBox;
    await box.clear();
  }

  Future<bool> containsKey(String key) async {
    final box = await _openBox;
    return box.containsKey(key);
  }

  Future<List<T>> getAll() async {
    final box = await _openBox;
    return box.values.toList();
  }
}
