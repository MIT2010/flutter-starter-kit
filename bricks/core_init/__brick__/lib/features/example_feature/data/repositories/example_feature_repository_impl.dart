import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/failure.dart';
import '../../../../core/logging/unexpected_error.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result.dart';
import '../../domain/repositories/example_feature_repository.dart';
import '../models/example_item_model.dart';

/// Real network call path: hits the shared [Dio] client and maps every
/// possible outcome onto [Result] — never throws, never returns a raw
/// backend error string to the caller.
@LazySingleton(as: ExampleFeatureRepository)
class ExampleFeatureRepositoryImpl implements ExampleFeatureRepository {
  ExampleFeatureRepositoryImpl(this._dio, this._logger);

  final Dio _dio;
  final Logger _logger;

  @override
  Future<Result<Failure, ExampleItem>> getExampleItem() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/posts/1');
      return Result.success(ExampleItem.fromJson(response.data!));
    } on DioException catch (e) {
      return Result.failure(mapDioError(e));
    } catch (e, stackTrace) {
      // Deliberately NOT a DioException — e.g. a response body that parsed
      // but didn't have the shape ExampleItem.fromJson expected. Routing
      // this through `unexpectedError` (rather than a bare `catch (_)`) is
      // the difference between it being visible in the log and it being
      // silently indistinguishable from a routine backend rejection — see
      // ADR-0011.
      return unexpectedError(
        _logger,
        'ExampleFeatureRepositoryImpl.getExampleItem: unexpected error',
        e,
        stackTrace,
      );
    }
  }
}
