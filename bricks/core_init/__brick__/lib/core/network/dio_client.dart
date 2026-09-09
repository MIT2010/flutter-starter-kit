import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/session_expiry_interceptor.dart';

/// The number of app-defined interceptors that must be attached below. Not
/// the same as `dio.interceptors.length` — Dio attaches its own internal
/// `ImplyContentTypeInterceptor` on construction, on top of these. A test
/// asserts each of these 3 specific interceptor types is present, so a
/// newly-added interceptor class can never silently ship unattached — see
/// the known production bug this guards against in docs/decisions.
///
/// The third slot is [SessionExpiryInterceptor] by default (401 -> log
/// out). Swap in [RefreshTokenInterceptor] here if your backend issues
/// refresh tokens — see docs/decisions/ADR-0012 — and update the list,
/// this count, and `dio_client_test.dart` together.
const expectedInterceptorCount = 3;

/// Provides the single shared [Dio] instance for the whole app.
///
/// Every interceptor class this app defines must appear in the list below.
/// This is deliberately the ONLY place `dio.interceptors.add*` is called —
/// do not create a second Dio instance or attach interceptors elsewhere.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    SessionExpiryInterceptor sessionExpiryInterceptor,
  ) {
    final ourInterceptors = [
      authInterceptor,
      loggingInterceptor,
      sessionExpiryInterceptor,
    ];
    assert(
      ourInterceptors.length == expectedInterceptorCount,
      'Every interceptor class must be listed here.',
    );

    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    dio.interceptors.addAll(ourInterceptors);
    return dio;
  }
}
