import 'dart:async';

/// Sebelumnya file ini mematikan GoogleFonts.config.allowRuntimeFetching
/// supaya test tidak diam-diam melakukan network call ke Google Fonts CDN.
///
/// Sejak AppTypography berpindah dari package google_fonts ke font Inter
/// yang di-bundle sebagai asset lokal (lihat pubspec.yaml package ini dan
/// lib/src/tokens/app_typography.dart), tidak ada lagi kode yang melakukan
/// fetch jaringan untuk font — baik saat test maupun saat aplikasi jalan
/// sungguhan. File ini sengaja dibiarkan sebagai override kosong (bukan
/// dihapus) supaya kalau nanti ada yang menambahkan dependency font
/// berbasis network lagi, tempat yang tepat untuk menjaganya tetap di sini.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}
