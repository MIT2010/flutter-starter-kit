import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/storage/temp_file_cleanup.dart';

void main() {
  late Directory tempDir;
  late TempFileCleanup cleanup;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('temp_file_cleanup_test_');
    cleanup = TempFileCleanup();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('deleteFile removes the file from disk', () async {
    final file = File('${tempDir.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
    expect(file.existsSync(), isTrue);

    await cleanup.deleteFile(file);

    expect(file.existsSync(), isFalse);
  });

  test('clearAll deletes every tracked file', () async {
    final a = File('${tempDir.path}/a.tmp')..writeAsBytesSync([1]);
    final b = File('${tempDir.path}/b.tmp')..writeAsBytesSync([2]);
    cleanup
      ..track(a)
      ..track(b);

    await cleanup.clearAll();

    expect(a.existsSync(), isFalse);
    expect(b.existsSync(), isFalse);
  });

  test('deleteFile on an already-missing file does not throw', () async {
    final file = File('${tempDir.path}/missing.tmp');
    expect(file.existsSync(), isFalse);

    await expectLater(cleanup.deleteFile(file), completes);
  });
}
