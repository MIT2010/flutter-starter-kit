import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/network/interceptors/session_expiry_interceptor.dart';

DioException _errorFor(String path, {int? statusCode = 401}) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response(requestOptions: requestOptions, statusCode: statusCode),
  );
}

void main() {
  group('isSessionExpired', () {
    test('is false for a 401 from the login endpoint '
        '(regression guard: a failed login must never force a logout)', () {
      expect(isSessionExpired(_errorFor('/auth/login')), isFalse);
    });

    test('is false for a non-401/403 error', () {
      expect(
        isSessionExpired(_errorFor('/users/me', statusCode: 500)),
        isFalse,
      );
    });

    test('is false when there is no response at all', () {
      expect(
        isSessionExpired(_errorFor('/users/me', statusCode: null)),
        isFalse,
      );
    });

    test('is true for a first-time 401 on a normal endpoint', () {
      expect(isSessionExpired(_errorFor('/users/me')), isTrue);
    });

    test('is true for a 403 on a normal endpoint', () {
      expect(isSessionExpired(_errorFor('/users/me', statusCode: 403)), isTrue);
    });
  });
}
