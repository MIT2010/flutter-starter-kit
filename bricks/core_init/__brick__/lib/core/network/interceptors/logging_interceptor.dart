import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../config/app_config.dart';

/// Field names (case-insensitive) that must never appear unredacted in logs.
///
/// Add more here whenever a new feature introduces a new sensitive field
/// (health data, biometric data, financial info, document numbers, etc.) —
/// do not disable logging instead of extending this list.
const sensitiveFieldNames = <String>{
  'authorization',
  'token',
  'accessToken',
  'access_token',
  'refreshToken',
  'refresh_token',
  'password',
  'newPassword',
  'confirmPassword',
  'secret',
  'apiKey',
  'api_key',
  'ssn',
  'creditCard',
  'credit_card',
  'cvv',
};

const _redacted = '[REDACTED]';

/// Logs request/response metadata with sensitive fields redacted.
///
/// Never logs `request.data` / `response.data` directly — always through
/// [redactSensitiveData] first. Defining this class is not enough on its
/// own — it must actually be added to the shared [Dio] instance's
/// interceptor list, see `dio_client.dart`.
///
/// Logging itself goes through the shared [Logger] (see
/// `core/logging/app_logger.dart`), gated by
/// [AppConfig.enableNetworkLogging] — disabled by default in
/// `config/production.json`.
@injectable
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.enableNetworkLogging) {
      _logger.d(
        '--> ${options.method} ${options.uri}\n'
        'headers: ${redactSensitiveData(options.headers)}\n'
        'body: ${redactSensitiveData(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.enableNetworkLogging) {
      _logger.i(
        '<-- ${response.statusCode} ${response.requestOptions.uri}\n'
        'body: ${redactSensitiveData(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.enableNetworkLogging) {
      _logger.e(
        '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}\n'
        'body: ${redactSensitiveData(err.response?.data)}',
        // Deliberately err.type (an enum), not the raw DioException — its
        // toString() isn't something this codebase controls, and a future
        // dio version could start embedding response detail there without
        // that counting as a breaking change. err.type can never do that.
        error: err.type,
      );
    }
    handler.next(err);
  }
}

final _sensitiveFieldNamesLower = sensitiveFieldNames
    .map((name) => name.toLowerCase())
    .toSet();

/// Recursively redacts any key in [sensitiveFieldNames] from maps, leaving
/// everything else untouched. Non-map payloads pass through unchanged since
/// there's no field name to key a redaction decision on.
dynamic redactSensitiveData(dynamic data) {
  if (data is Map) {
    return data.map((key, value) {
      final isSensitive = _sensitiveFieldNamesLower.contains(
        key.toString().toLowerCase(),
      );
      return MapEntry(
        key,
        isSensitive ? _redacted : redactSensitiveData(value),
      );
    });
  }
  if (data is List) {
    return data.map(redactSensitiveData).toList();
  }
  return data;
}
