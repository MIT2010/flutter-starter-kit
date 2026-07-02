import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// Menempelkan access token ke setiap request secara otomatis, dan
/// mencoba refresh token sekali secara transparan saat menerima 401
/// sebelum meneruskan error ke pemanggil.
///
/// Pengecekan status code dilakukan langsung dari [DioException] mentah
/// (bukan `AppException` hasil mapping ErrorInterceptor) karena interceptor
/// ini terdaftar SEBELUM ErrorInterceptor — Dio menjalankan onError setiap
/// interceptor sesuai urutan pendaftarannya (bukan dibalik).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
    required this.dio,
    this.refreshToken,
  });

  final Future<String?> Function() getAccessToken;
  final Future<bool> Function()? refreshToken;
  final Dio dio;

  Future<bool>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    AppLogger.debug('[HTTP] → ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried =
        err.requestOptions.extra['retriedAfterRefresh'] == true;

    if (!isUnauthorized || alreadyRetried || refreshToken == null) {
      handler.next(err);
      return;
    }

    AppLogger.debug(
      '[HTTP] 401 pada ${err.requestOptions.path}, mencoba refresh token...',
    );

    final refreshed = await _refreshTokenOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions
        ..extra['retriedAfterRefresh'] = true;
      final response = await dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  /// Memastikan hanya ada satu request refresh token yang berjalan
  /// meski beberapa request gagal dengan 401 secara bersamaan.
  Future<bool> _refreshTokenOnce() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = refreshToken!();
    _refreshInFlight = future;
    future.whenComplete(() => _refreshInFlight = null);
    return future;
  }
}
