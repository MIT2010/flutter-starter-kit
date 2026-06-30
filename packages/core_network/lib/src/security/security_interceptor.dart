import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_app/flutter_secure_app.dart';

/// Service untuk inisialisasi RASP (Runtime Application Self-Protection)
/// dari package flutter_secure_app.
///
/// CATATAN: RASP hanya berjalan di Android & iOS — package ini
/// memakai Platform.isIOS/isAndroid yang TIDAK didukung di Web.
/// Di Web, security check di-skip sepenuhnya dan dianggap selalu aman
/// karena PWA tidak punya konsep root/jailbreak.
class AppSecurityGuard {
  AppSecurityGuard._();

  static bool _isInitialized = false;
  static bool _isSafe = true;
  static final List<String> _detectedThreats = [];

  static bool get isSafe => _isSafe;
  static List<String> get detectedThreats => List.unmodifiable(_detectedThreats);

  /// Inisialisasi RASP engine — panggil sekali di bootstrap.
  /// Otomatis di-skip jika berjalan di Web.
  static Future<void> init() async {
    if (_isInitialized) return;

    // RASP tidak support Web — skip sepenuhnya
    if (kIsWeb) {
      AppLogger.info('[Security] RASP skipped — not supported on Web');
      _isSafe = true;
      _isInitialized = true;
      return;
    }

    try {
      await FlutterSecureApp().init(
        isProdEnv: AppEnv.isProduction,
        onThreatDetected: (threatType) {
          _detectedThreats.add(threatType.toString());
          AppLogger.warning('[Security] Threat detected: $threatType');
        },
      );

      _isSafe = FlutterSecureApp().isSafe;
      _isInitialized = true;

      AppLogger.info('[Security] RASP initialized. isSafe: $_isSafe');
    } catch (e) {
      AppLogger.warning('[Security] RASP init failed: $e');
      // Jangan blokir app jika init gagal — fail open, bukan fail closed
      _isSafe = true;
    }
  }
}

/// Interceptor yang memblokir request jika device terdeteksi tidak aman.
/// Dipasang di ApiClient setelah AppSecurityGuard.init() dipanggil.
class SecurityInterceptor extends Interceptor {
  SecurityInterceptor({this.enableInDevelopment = false});

  final bool enableInDevelopment;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Skip pengecekan di development kecuali eksplisit diaktifkan
    if (AppEnv.isDevelopment && !enableInDevelopment) {
      return handler.next(options);
    }

    if (!AppSecurityGuard.isSafe) {
      AppLogger.warning(
        '[Security] Request diblokir — device tidak aman: '
        '${AppSecurityGuard.detectedThreats.join(', ')}',
      );

      return handler.reject(
        DioException(
          requestOptions: options,
          error: SecurityException(
            'Aplikasi tidak dapat berjalan di perangkat ini',
          ),
          type: DioExceptionType.cancel,
        ),
      );
    }

    handler.next(options);
  }
}

/// Exception khusus untuk security violations
class SecurityException implements Exception {
  const SecurityException(this.message);
  final String message;

  @override
  String toString() => 'SecurityException: $message';
}
