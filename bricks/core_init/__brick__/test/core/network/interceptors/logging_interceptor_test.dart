import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/config/app_config.dart';
import 'package:{{project_name}}/core/network/interceptors/logging_interceptor.dart';

class _MockLogger extends Mock implements Logger {}

class _NoopRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}

class _NoopResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}
}

class _NoopErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}

void main() {
  // These verify the interceptor calls the logger appropriately for
  // whatever AppConfig.enableNetworkLogging currently resolves to — written
  // this way so the same test file is valid whether run plain (defaults to
  // true, per config/development.json) or with
  // `--dart-define-from-file=config/production.json` (false). That's the
  // real proof the gate works, not something one hardcoded expectation
  // could show on its own.
  group('logging gated by AppConfig.enableNetworkLogging', () {
    late _MockLogger logger;
    late LoggingInterceptor interceptor;

    setUp(() {
      logger = _MockLogger();
      interceptor = LoggingInterceptor(logger);
      when(() => logger.d(any())).thenReturn(null);
      when(() => logger.i(any())).thenReturn(null);
      when(() => logger.e(any(), error: any(named: 'error'))).thenReturn(null);
    });

    test('onRequest', () {
      interceptor.onRequest(RequestOptions(path: '/x'), _NoopRequestHandler());
      if (AppConfig.enableNetworkLogging) {
        verify(() => logger.d(any())).called(1);
      } else {
        verifyNever(() => logger.d(any()));
      }
    });

    test('onResponse', () {
      final requestOptions = RequestOptions(path: '/x');
      interceptor.onResponse(
        Response(requestOptions: requestOptions, statusCode: 200),
        _NoopResponseHandler(),
      );
      if (AppConfig.enableNetworkLogging) {
        verify(() => logger.i(any())).called(1);
      } else {
        verifyNever(() => logger.i(any()));
      }
    });

    test('onError', () {
      final requestOptions = RequestOptions(path: '/x');
      interceptor.onError(
        DioException(requestOptions: requestOptions),
        _NoopErrorHandler(),
      );
      if (AppConfig.enableNetworkLogging) {
        verify(() => logger.e(any(), error: any(named: 'error'))).called(1);
      } else {
        verifyNever(() => logger.e(any(), error: any(named: 'error')));
      }
    });

    test('onError never passes the raw DioException as the logged error '
        '(regression guard: DioException.toString() is an upstream '
        'implementation detail, not a redaction guarantee — see ADR-0008)', () {
      interceptor.onError(
        DioException(requestOptions: RequestOptions(path: '/x')),
        _NoopErrorHandler(),
      );
      if (AppConfig.enableNetworkLogging) {
        final captured = verify(
          () => logger.e(any(), error: captureAny(named: 'error')),
        ).captured;
        expect(captured.single, isNot(isA<DioException>()));
      }
    });
  });

  group('redactSensitiveData', () {
    test('redacts every known sensitive field name', () {
      final input = {
        'authorization': 'Bearer secret-token',
        'password': 'hunter2',
        'accessToken': 'abc123',
        'username': 'not-sensitive',
      };

      final result = redactSensitiveData(input) as Map;

      expect(result['authorization'], '[REDACTED]');
      expect(result['password'], '[REDACTED]');
      expect(result['accessToken'], '[REDACTED]');
      expect(result['username'], 'not-sensitive');
    });

    test('redacts sensitive fields nested inside maps and lists', () {
      final input = {
        'user': {'name': 'Ada', 'password': 'hunter2'},
        'items': [
          {'token': 'abc'},
          {'title': 'fine'},
        ],
      };

      final result = redactSensitiveData(input) as Map;

      expect((result['user'] as Map)['password'], '[REDACTED]');
      expect((result['user'] as Map)['name'], 'Ada');
      expect((result['items'] as List)[0]['token'], '[REDACTED]');
      expect((result['items'] as List)[1]['title'], 'fine');
    });

    test('is case-insensitive on field names', () {
      final input = {'Authorization': 'Bearer x', 'PASSWORD': 'y'};

      final result = redactSensitiveData(input) as Map;

      expect(result['Authorization'], '[REDACTED]');
      expect(result['PASSWORD'], '[REDACTED]');
    });

    test('leaves non-map, non-list payloads untouched', () {
      expect(redactSensitiveData('plain string'), 'plain string');
      expect(redactSensitiveData(null), isNull);
    });
  });
}
