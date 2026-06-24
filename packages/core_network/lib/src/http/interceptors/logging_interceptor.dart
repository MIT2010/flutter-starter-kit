import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// Log semua response dari server. Hanya aktif di mode development.
class LoggingInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (AppEnv.isDevelopment) {
      AppLogger.debug(
        '[HTTP] ← ${response.statusCode} ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }
}
