import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../models/api_response.dart';
import '../models/response_parser.dart';

/// HTTP client terpusat berbasis Dio.
/// Di-setup sekali di bootstrap, diakses via DI.
class ApiClient {
  ApiClient({required Future<String?> Function() getAccessToken})
      : _dio = _createDio(getAccessToken);

  final Dio _dio;

  static Dio _createDio(Future<String?> Function() getAccessToken) {
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
      AuthInterceptor(getAccessToken: getAccessToken),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  /// GET request — otomatis parse response ke ApiResponse<T>
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

  /// POST request
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

  /// PUT request
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

  /// PATCH request
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

  /// DELETE request
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
