import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_app/flutter_secure_app.dart';

/// Helper untuk setup certificate pinning menggunakan flutter_secure_app.
///
/// CATATAN PENTING untuk Let's Encrypt:
/// Certificate Let's Encrypt diperbarui otomatis setiap 90 hari.
/// SHA-256 fingerprint akan BERUBAH setiap kali certificate diperbarui.
///
/// REKOMENDASI untuk starter kit ini (keamanan standar, bukan banking):
/// JANGAN aktifkan certificate pinning kecuali kamu punya:
/// 1. Proses CI/CD yang bisa update fingerprint otomatis, ATAU
/// 2. SPKI pinning ke public key yang lebih stabil dari leaf certificate
///
/// Cara mendapatkan SHA-256 fingerprint:
///   openssl s_client -servername api.example.com \
///     -connect api.example.com:443 < /dev/null 2>/dev/null | \
///     openssl x509 -fingerprint -sha256 -noout
class CertificatePinning {
  CertificatePinning._();

  /// Pasang certificate pinning ke Dio instance.
  /// Hanya panggil ini jika benar-benar dibutuhkan (high-risk app).
  static void apply(
    Dio dio, {
    required List<String> allowedFingerprints,
    bool bypassForLocalhost = false,
  }) {
    dio.interceptors.add(
      SslPinningInterceptor(
        allowedFingerprints: allowedFingerprints,
        bypassForLocalhost: bypassForLocalhost,
      ),
    );
    AppLogger.info('[Security] Certificate pinning active');
  }
}
