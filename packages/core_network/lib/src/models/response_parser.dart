import 'package:core/core.dart';
import 'api_response.dart';

/// Menangani semua variasi format response backend dan
/// mengubahnya menjadi ApiResponse yang konsisten.
///
/// Variasi yang ditangani:
/// 1. { "status": "ok"|"nok", "message": "...", "data": ... }
/// 2. { "status": "ok"|"nok", "messages": [...], "data": ... }
/// 3. { "status": true|false, "msg": "...", "data": ... }
/// 4. { "result": "success"|"error", "message": "...", "data": ... }
class ResponseParser {
  ResponseParser._();

  static ApiResponse<T> parse<T>(
    Map<String, dynamic> json,
    T Function(Object? json)? fromData,
  ) {
    try {
      final isSuccess = _parseIsSuccess(json);
      final message = _parseMessage(json);
      final messages = _parseMessages(json);
      final data = _parseData<T>(json, fromData);

      return ApiResponse<T>(
        isSuccess: isSuccess,
        message: message,
        messages: messages,
        data: data,
      );
    } catch (e, st) {
      AppLogger.error('ResponseParser error', e, st);
      return ApiResponse<T>(
        isSuccess: false,
        message: 'Terjadi kesalahan saat memproses response',
      );
    }
  }

  /// Deteksi field status — bisa "status" string, "status" boolean, atau "result"
  static bool _parseIsSuccess(Map<String, dynamic> json) {
    // Variasi 4: field "result"
    if (json.containsKey('result')) {
      final result = json['result'];
      if (result is String) {
        return result.toLowerCase() == 'success';
      }
    }

    // Variasi 1 & 2: field "status" string
    // Variasi 3: field "status" boolean
    if (json.containsKey('status')) {
      final status = json['status'];
      if (status is bool) return status;
      if (status is String) return status.toLowerCase() == 'ok';
    }

    return false;
  }

  /// Deteksi field pesan — bisa "message" atau "msg"
  static String _parseMessage(Map<String, dynamic> json) {
    // Cek "message" dulu, lalu "msg"
    final raw = json['message'] ?? json['msg'];

    if (raw == null) return '';

    // Kalau message ternyata list (beberapa backend kirim begini)
    if (raw is List) return raw.join(', ');

    return raw.toString();
  }

  /// Deteksi field "messages" — list of error strings
  static List<String> _parseMessages(Map<String, dynamic> json) {
    final raw = json['messages'];
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  /// Parse field "data" menggunakan converter yang diberikan
  static T? _parseData<T>(
    Map<String, dynamic> json,
    T Function(Object? json)? fromData,
  ) {
    if (fromData == null) return null;
    final data = json['data'];
    if (data == null) return null;
    return fromData(data);
  }
}
