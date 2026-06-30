import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../models/api_response.dart';
import '../models/response_parser.dart';
import '../security/security_interceptor.dart';

/// HTTP client terpusat berbasis Dio.
/// Di-setup sekali di bootstrap, diakses via DI.
class ApiClient {
  ApiClient({
    required Future<String?> Function() getAccessToken,
    bool enableSecurityCheck = true,
  }) : _dio = _createDio(
          getAccessToken: getAccessToken,
          enableSecurityCheck: enableSecurityCheck,
        );

  final Dio _dio;

  static Dio _createDio({
    required Future<String?> Function() getAccessToken,
    required bool enableSecurityCheck,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      // Security check — dijalankan pertama sebelum request apapun
      if (enableSecurityCheck)
        SecurityInterceptor(),

      // Auth — attach token
      AuthInterceptor(getAccessToken: getAccessToken),

      // Error mapping
      ErrorInterceptor(),

      // Logging — hanya di development
      LoggingInterceptor(),
    ]);

    return dio;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromData,
    Options? options,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    return ResponseParser.parse<T>(response.data!, fromData);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(Object? json)? fromData,
    Options? options,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
    return ResponseParser.parse<T>(response.data!, fromData);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(Object? json)? fromData,
    Options? options,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
    return ResponseParser.parse<T>(response.data!, fromData);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(Object? json)? fromData,
    Options? options,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
    return ResponseParser.parse<T>(response.data!, fromData);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(Object? json)? fromData,
    Options? options,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
    return ResponseParser.parse<T>(response.data!, fromData);
  }
}
