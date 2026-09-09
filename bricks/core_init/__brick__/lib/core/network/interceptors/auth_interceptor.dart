import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../storage/hive_client.dart';

/// Attaches the stored bearer token (if any) to every outgoing request.
///
/// Defining this class is not enough on its own — it must actually be added
/// to the shared [Dio] instance's interceptor list, see `dio_client.dart`.
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._hiveClient);

  final HiveClient _hiveClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _hiveClient.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
