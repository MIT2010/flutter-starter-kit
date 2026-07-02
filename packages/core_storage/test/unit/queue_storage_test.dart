import 'dart:io';

import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('queue_storage_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  QueueItem buildItem({
    String id = 'item-1',
    DateTime? createdAt,
    QueueItemStatus status = QueueItemStatus.pending,
  }) {
    return QueueItem(
      id: id,
      type: 'test_type',
      data: const {'foo': 'bar'},
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      status: status,
    );
  }

  group('QueueStorage', () {
    late QueueStorage storage;

    setUp(() {
      storage = QueueStorage(
        'test_queue_${DateTime.now().microsecondsSinceEpoch}',
      );
    });

    test('save dan getAll mengembalikan item yang sama', () async {
      final item = buildItem();
      await storage.save(item);

      expect(await storage.getAll(), [item]);
    });

    test('getAll mengurutkan berdasarkan createdAt (FIFO)', () async {
      final older = buildItem(id: 'a', createdAt: DateTime(2026, 1, 1));
      final newer = buildItem(id: 'b', createdAt: DateTime(2026, 1, 2));

      // Simpan urutan terbalik supaya benar-benar menguji sorting-nya.
      await storage.save(newer);
      await storage.save(older);

      final all = await storage.getAll();
      expect(all.map((i) => i.id).toList(), ['a', 'b']);
    });

    test('getByStatus hanya mengembalikan item dengan status tsb', () async {
      await storage.save(buildItem(id: 'a', status: QueueItemStatus.pending));
      await storage.save(buildItem(id: 'b', status: QueueItemStatus.failed));

      final pending = await storage.getByStatus(QueueItemStatus.pending);
      expect(pending.map((i) => i.id).toList(), ['a']);
    });

    test('save dengan id sama menimpa item lama (upsert)', () async {
      await storage.save(buildItem(id: 'a', status: QueueItemStatus.pending));
      await storage.save(buildItem(id: 'a', status: QueueItemStatus.failed));

      final all = await storage.getAll();
      expect(all.length, 1);
      expect(all.first.status, QueueItemStatus.failed);
    });

    test('remove menghapus item tertentu saja', () async {
      await storage.save(buildItem(id: 'a'));
      await storage.save(buildItem(id: 'b'));
      await storage.remove('a');

      final all = await storage.getAll();
      expect(all.map((i) => i.id).toList(), ['b']);
    });

    test('clear menghapus semua item', () async {
      await storage.save(buildItem(id: 'a'));
      await storage.save(buildItem(id: 'b'));
      await storage.clear();

      expect(await storage.getAll(), isEmpty);
    });

    test('pendingCount hanya menghitung item berstatus pending', () async {
      await storage.save(buildItem(id: 'a', status: QueueItemStatus.pending));
      await storage.save(buildItem(id: 'b', status: QueueItemStatus.pending));
      await storage.save(buildItem(id: 'c', status: QueueItemStatus.completed));

      expect(await storage.pendingCount, 2);
    });
  });
}
