import 'package:core_storage/core_storage.dart';

/// Kontrak yang harus diimplementasikan setiap fitur yang
/// punya tipe data tersendiri di queue.
///
/// Setiap fitur (assessment, profile, dll) implementasikan ini
/// untuk mendefinisikan cara mengirim data spesifiknya ke API.
abstract class QueueHandler {
  /// Tipe operasi yang ditangani handler ini — harus unik
  /// Contoh: 'assessment_answer', 'update_profile'
  String get type;

  /// Eksekusi pengiriman data ke server.
  /// Return true jika berhasil, false jika gagal (akan di-retry).
  /// Throw exception untuk error yang tidak bisa di-retry (misal validasi).
  Future<bool> handle(QueueItem item);
}
