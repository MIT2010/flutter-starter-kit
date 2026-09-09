import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/network/interceptors/auth_interceptor.dart';
import 'package:{{project_name}}/core/storage/hive_client.dart';

class _MockHiveClient extends Mock implements HiveClient {}

class _RecordingHandler extends RequestInterceptorHandler {
  RequestOptions? passedOptions;

  @override
  void next(RequestOptions requestOptions) {
    passedOptions = requestOptions;
  }
}

void main() {
  late _MockHiveClient hiveClient;
  late AuthInterceptor interceptor;

  setUp(() {
    hiveClient = _MockHiveClient();
    interceptor = AuthInterceptor(hiveClient);
  });

  test('attaches a Bearer header when a token is stored', () {
    when(() => hiveClient.authToken).thenReturn('my-token');
    final handler = _RecordingHandler();

    interceptor.onRequest(RequestOptions(path: '/x'), handler);

    expect(handler.passedOptions?.headers['Authorization'], 'Bearer my-token');
  });

  test('does not attach an Authorization header when no token is stored', () {
    when(() => hiveClient.authToken).thenReturn(null);
    final handler = _RecordingHandler();

    interceptor.onRequest(RequestOptions(path: '/x'), handler);

    expect(
      handler.passedOptions?.headers.containsKey('Authorization'),
      isFalse,
    );
  });
}
