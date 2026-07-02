import 'dart:io';

import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_storage_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('HiveStorage<String>', () {
    late HiveStorage<String> storage;

    setUp(() {
      storage = HiveStorage<String>(
        'test_box_${DateTime.now().microsecondsSinceEpoch}',
      );
    });

    test('put dan get mengembalikan value yang sama', () async {
      await storage.put('key1', 'value1');
      expect(await storage.get('key1'), 'value1');
    });

    test('get mengembalikan null untuk key yang tidak ada', () async {
      expect(await storage.get('tidak-ada'), isNull);
    });

    test('put dengan key sama menimpa value lama', () async {
      await storage.put('key1', 'value1');
      await storage.put('key1', 'value2');
      expect(await storage.get('key1'), 'value2');
    });

    test('containsKey membedakan key yang ada dan tidak', () async {
      await storage.put('key1', 'value1');
      expect(await storage.containsKey('key1'), true);
      expect(await storage.containsKey('key2'), false);
    });

    test('delete menghapus key tertentu saja', () async {
      await storage.put('key1', 'value1');
      await storage.put('key2', 'value2');
      await storage.delete('key1');

      expect(await storage.get('key1'), isNull);
      expect(await storage.get('key2'), 'value2');
    });

    test('getAll mengembalikan semua value yang tersimpan', () async {
      await storage.put('a', '1');
      await storage.put('b', '2');
      expect(await storage.getAll(), containsAll(<String>['1', '2']));
    });

    test('clear menghapus semua data di box', () async {
      await storage.put('a', '1');
      await storage.put('b', '2');
      await storage.clear();
      expect(await storage.getAll(), isEmpty);
    });
  });
}
