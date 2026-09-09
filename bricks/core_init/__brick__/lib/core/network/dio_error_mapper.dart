import 'package:dio/dio.dart';

import '../failure.dart';

/// Maps a [DioException] onto a generic, user-safe [Failure].
///
/// This is the one place allowed to look at the raw exception / response
/// body. Everything past this function only ever sees a [Failure] — see
/// ground rule "repository error handling must never pass a raw backend
/// error string directly to UI-facing state."
Failure mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Could not establish a secure connection.');
    case DioExceptionType.cancel:
      return const UnknownFailure('The request was cancelled.');
    case DioExceptionType.badResponse:
      return _mapStatusCode(error.response?.statusCode);
    case DioExceptionType.unknown:
      return const UnknownFailure();
  }
}

Failure _mapStatusCode(int? statusCode) {
  if (statusCode == 401 || statusCode == 403) {
    return const UnauthorizedFailure();
  }
  if (statusCode != null && statusCode >= 500) {
    return const ServerFailure();
  }
  return const UnknownFailure();
}
