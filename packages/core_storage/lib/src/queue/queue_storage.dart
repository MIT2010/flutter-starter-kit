import 'dart:convert';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'queue_item.dart';

/// Storage untuk persist queue items ke Hive.
/// Setiap jenis queue (assessment, generic) punya box terpisah
/// berdasarkan [boxName] agar tidak saling tercampur.
class QueueStorage {
  QueueStorage(this.boxName);

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> get _openBox async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  /// Simpan atau update item
  Future<void> save(QueueItem item) async {
    final box = await _openBox;
    await box.put(item.id, jsonEncode(item.toJson()));
  }

  /// Ambil semua item, urutkan berdasarkan createdAt (FIFO untuk display)
  Future<List<QueueItem>> getAll() async {
    final box = await _openBox;
    final items = box.values
        .map(
          (raw) => QueueItem.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  /// Ambil item dengan status tertentu
  Future<List<QueueItem>> getByStatus(QueueItemStatus status) async {
    final all = await getAll();
    return all.where((item) => item.status == status).toList();
  }

  /// Hapus item — dipanggil setelah berhasil sync
  Future<void> remove(String id) async {
    final box = await _openBox;
    await box.delete(id);
  }

  /// Hapus semua item — berguna untuk testing atau reset
  Future<void> clear() async {
    final box = await _openBox;
    await box.clear();
  }

  /// Jumlah item yang masih pending
  Future<int> get pendingCount async {
    final pending = await getByStatus(QueueItemStatus.pending);
    return pending.length;
  }
}
