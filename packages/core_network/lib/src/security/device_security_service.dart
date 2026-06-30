import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

/// Hasil pengecekan keamanan device
class DeviceSecurityResult {
  const DeviceSecurityResult({
    required this.isJailBroken,
    required this.isRealDevice,
    required this.isMockLocation,
  });

  final bool isJailBroken;
  final bool isRealDevice;
  final bool isMockLocation;

  bool get isEmulator => !isRealDevice;

  /// Device aman untuk menjalankan operasi sensitif
  bool get isSafe => !isJailBroken && isRealDevice && !isMockLocation;

  @override
  String toString() => 'DeviceSecurityResult('
      'isJailBroken: $isJailBroken, '
      'isRealDevice: $isRealDevice, '
      'isMockLocation: $isMockLocation)';
}

/// Service untuk mengecek keamanan device menggunakan package safe_device.
///
/// Pakai ini di bootstrap atau sebelum operasi sensitif
/// seperti payment atau akses data rahasia.
///
/// CATATAN: Root/jailbreak detection adalah best-effort approach.
/// Attacker yang menggunakan tools seperti Magisk Hide bisa bypass deteksi ini.
/// Jangan jadikan satu-satunya lapisan keamanan.
class DeviceSecurityService {
  DeviceSecurityService._();

  static DeviceSecurityResult? _cachedResult;

  /// Cek keamanan device — hasil di-cache agar tidak berulang kali cek
  static Future<DeviceSecurityResult> check() async {
    if (_cachedResult != null) return _cachedResult!;

    // Web tidak support native security check
    if (kIsWeb) {
      _cachedResult = const DeviceSecurityResult(
        isJailBroken: false,
        isRealDevice: true,
        isMockLocation: false,
      );
      return _cachedResult!;
    }

    try {
      final results = await Future.wait([
        SafeDevice.isJailBroken,
        SafeDevice.isRealDevice,
        SafeDevice.isMockLocation,
      ]);

      _cachedResult = DeviceSecurityResult(
        isJailBroken: results[0],
        isRealDevice: results[1],
        isMockLocation: results[2],
      );

      AppLogger.info('[Security] Device check: $_cachedResult');
      return _cachedResult!;
    } catch (e) {
      AppLogger.warning('[Security] Device check failed: $e');
      // Default aman jika pengecekan gagal — jangan blokir user
      // karena false positive
      _cachedResult = const DeviceSecurityResult(
        isJailBroken: false,
        isRealDevice: true,
        isMockLocation: false,
      );
      return _cachedResult!;
    }
  }

  /// Reset cache — berguna untuk testing
  static void resetCache() => _cachedResult = null;
}
