import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// Mengubah DioException menjadi AppException yang konsisten.
/// Dipasang sebagai interceptor terakhir di Dio.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '[HTTP] ✗ ${err.response?.statusCode} ${err.requestOptions.path}',
      err,
      err.stackTrace,
    );

    final exception = _mapToAppException(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  AppException _mapToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Koneksi timeout, periksa jaringan kamu',
        );

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final message = _extractMessage(data);

        return switch (statusCode) {
          401 => UnauthorizedException(message: message ?? 'Unauthorized'),
          404 => NotFoundException(message: message ?? 'Tidak ditemukan'),
          422 => ValidationException(
            message: message ?? 'Validasi gagal',
            messages: _extractMessages(data),
            statusCode: 422,
          ),
          _ => ServerException(
            message: message ?? 'Terjadi kesalahan pada server',
            statusCode: statusCode,
          ),
        };

      default:
        return AppException(message: err.message ?? 'Terjadi kesalahan');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final raw = data['message'] ?? data['msg'];
    if (raw is List) return (raw).join(', ');
    return raw?.toString();
  }

  List<String> _extractMessages(dynamic data) {
    if (data is! Map<String, dynamic>) return [];
    final raw = data['messages'];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }
}
