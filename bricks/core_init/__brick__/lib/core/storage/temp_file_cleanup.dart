import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Deletes files written to temp storage.
///
/// Any code path that writes to [getTemporaryDirectory] (captured photos,
/// downloaded/cached documents, scanned images) MUST call [deleteFile] once
/// the file is no longer needed, or register the path so [clearAll] can
/// sweep it — never leave user-submitted files in temp storage indefinitely.
@lazySingleton
class TempFileCleanup {
  final _trackedPaths = <String>{};

  /// Call right after writing a file to temp storage so it's swept even if
  /// the feature-specific cleanup call site is missed.
  void track(File file) => _trackedPaths.add(file.path);

  Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
    _trackedPaths.remove(file.path);
  }

  /// Deletes every tracked temp file. Safe to call from app startup/dispose
  /// as a catch-all in case a feature-specific delete call was missed.
  Future<void> clearAll() async {
    for (final path in _trackedPaths.toList()) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _trackedPaths.clear();
  }
}
