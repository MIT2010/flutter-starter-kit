import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/failure.dart';
import 'package:{{project_name}}/core/logging/unexpected_error.dart';
import 'package:{{project_name}}/core/result.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  late _MockLogger logger;

  setUp(() => logger = _MockLogger());

  test('logs the error with its stack trace and returns UnknownFailure', () {
    final stackTrace = StackTrace.current;

    final result = unexpectedError<int>(
      logger,
      'Foo.bar',
      Exception('boom'),
      stackTrace,
    );

    verify(
      () => logger.e(
        'Foo.bar',
        error: any(named: 'error'),
        stackTrace: stackTrace,
      ),
    ).called(1);
    expect(result, isA<ResultFailure<Failure, int>>());
    result.fold(
      onFailure: (f) => expect(f, isA<UnknownFailure>()),
      onSuccess: (_) => fail('expected a failure'),
    );
  });

  test('returns the supplied failure when one is passed', () {
    final result = unexpectedError<String>(
      logger,
      'Foo.baz',
      'not an exception object',
      StackTrace.current,
      failure: const CacheFailure(),
    );

    result.fold(
      onFailure: (f) => expect(f, isA<CacheFailure>()),
      onSuccess: (_) => fail('expected a failure'),
    );
  });
}
