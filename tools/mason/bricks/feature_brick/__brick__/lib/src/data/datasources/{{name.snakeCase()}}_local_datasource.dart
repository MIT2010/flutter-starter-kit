import 'dart:convert';
import 'package:core_storage/core_storage.dart';
import '../models/{{name.snakeCase()}}_model.dart';

abstract class {{name.pascalCase()}}LocalDataSource {
  Future<void> cache{{name.pascalCase()}}({{name.pascalCase()}}Model model);
  Future<{{name.pascalCase()}}Model?> getCached{{name.pascalCase()}}(String id);
}

/// Cache sederhana per-id supaya {{name.snakeCase()}} terakhir yang diambil
/// masih bisa dibaca saat offline. Sesuaikan strategi cache-nya
/// (per-id, satu list, TTL, dll) sesuai kebutuhan fitur ini.
class {{name.pascalCase()}}LocalDataSourceImpl implements {{name.pascalCase()}}LocalDataSource {
  {{name.pascalCase()}}LocalDataSourceImpl(this._storage);

  final HiveStorage<String> _storage;

  @override
  Future<void> cache{{name.pascalCase()}}({{name.pascalCase()}}Model model) {
    return _storage.put(model.id, jsonEncode(model.toJson()));
  }

  @override
  Future<{{name.pascalCase()}}Model?> getCached{{name.pascalCase()}}(String id) async {
    final raw = await _storage.get(id);
    if (raw == null) return null;
    return {{name.pascalCase()}}Model.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
