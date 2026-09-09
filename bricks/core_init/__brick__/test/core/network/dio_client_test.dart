import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/network/dio_client.dart';
import 'package:{{project_name}}/core/network/interceptors/auth_interceptor.dart';
import 'package:{{project_name}}/core/network/interceptors/logging_interceptor.dart';
import 'package:{{project_name}}/core/network/interceptors/session_expiry_interceptor.dart';
import 'package:{{project_name}}/core/storage/hive_client.dart';
import 'package:{{project_name}}/app/auth_status_notifier.dart';

class _MockHiveClient extends Mock implements HiveClient {}

class _MockLogger extends Mock implements Logger {}

class _MockAuthStatusNotifier extends Mock implements AuthStatusNotifier {}

// injectable requires @module classes to be abstract; this test-only
// subclass exists because NetworkModule itself can't be instantiated
// directly (its dio() method already has a full body — nothing to
// implement, just something concrete to construct).
class _TestNetworkModule extends NetworkModule {}

void main() {
  test('every defined interceptor is attached to the shared Dio instance '
      '(regression guard: a defined-but-unattached interceptor must be '
      'structurally impossible)', () {
    final hiveClient = _MockHiveClient();
    final module = _TestNetworkModule();

    final dio = module.dio(
      AuthInterceptor(hiveClient),
      LoggingInterceptor(_MockLogger()),
      SessionExpiryInterceptor(_MockAuthStatusNotifier()),
    );

    // dio.interceptors.length isn't compared directly against
    // expectedInterceptorCount: Dio attaches its own internal
    // ImplyContentTypeInterceptor on construction on top of these 3.
    expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
    expect(dio.interceptors.whereType<LoggingInterceptor>(), hasLength(1));
    expect(
      dio.interceptors.whereType<SessionExpiryInterceptor>(),
      hasLength(1),
    );
    expect(
      dio.interceptors.whereType<Interceptor>().length,
      greaterThanOrEqualTo(expectedInterceptorCount),
    );
  });
}
