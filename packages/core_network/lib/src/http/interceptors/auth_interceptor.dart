import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// Menempelkan access token ke setiap request secara otomatis.
/// Token diambil dari SecureStorage melalui callback yang diberikan saat init.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
  });

  final Future<String?> Function() getAccessToken;

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
}
