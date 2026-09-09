import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/network/interceptors/refresh_token_interceptor.dart';

DioException _errorFor(
  String path, {
  int? statusCode = 401,
  bool alreadyRetried = false,
}) {
  final requestOptions = RequestOptions(
    path: path,
    extra: alreadyRetried ? {'retriedAfterRefresh': true} : {},
  );
  return DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response(requestOptions: requestOptions, statusCode: statusCode),
  );
}

void main() {
  group('shouldAttemptRefresh', () {
    test(
      'is false for a 401 from the login endpoint '
      '(regression guard: a failed login must never trigger a refresh loop)',
      () {
        expect(shouldAttemptRefresh(_errorFor('/auth/login')), isFalse);
      },
    );

    test('is false for a 401 from the refresh endpoint itself', () {
      expect(shouldAttemptRefresh(_errorFor('/auth/refresh')), isFalse);
    });

    test('is false when the request was already retried once', () {
      expect(
        shouldAttemptRefresh(_errorFor('/users/me', alreadyRetried: true)),
        isFalse,
      );
    });

    test('is false for non-401 errors', () {
      expect(
        shouldAttemptRefresh(_errorFor('/users/me', statusCode: 500)),
        isFalse,
      );
    });

    test('is true for a first-time 401 on a normal endpoint', () {
      expect(shouldAttemptRefresh(_errorFor('/users/me')), isTrue);
    });
  });
}
