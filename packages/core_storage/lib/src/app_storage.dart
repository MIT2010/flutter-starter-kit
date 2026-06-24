import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Inisialisasi storage — dipanggil sekali di bootstrap sebelum app berjalan.
class AppStorage {
  AppStorage._();

  static Future<void> init() async {
    await Hive.initFlutter();
  }
}
