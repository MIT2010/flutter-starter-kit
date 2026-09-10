import 'package:logger/logger.dart';

import '../failure.dart';
import '../result.dart';

/// Logs an unexpected error with its stack trace, then returns a generic
/// [Result.failure].
///
/// This is for the `catch (e, stackTrace)` branch of a repository method —
/// the one that catches what a `DioException` handler wouldn't: a response
/// body that parsed but didn't have the shape a model expected, a bad
/// cast, anything genuinely unforeseen. That branch must never swallow the
/// error silently (it would be indistinguishable from a routine backend
/// rejection), and it must not leak the raw error to the UI. This does
/// both: logs the detail for a developer, returns a safe [Failure] for the
/// caller. See ADR-0011.
///
/// ```dart
/// } on DioException catch (e) {
///   return Result.failure(mapDioError(e));
/// } catch (e, stackTrace) {
///   return unexpectedError(_logger, 'FooRepository.getFoo', e, stackTrace);
/// }
/// ```
Result<Failure, T> unexpectedError<T>(
  Logger logger,
  String context,
  Object error,
  StackTrace stackTrace, {
  Failure failure = const UnknownFailure(),
}) {
  logger.e(context, error: error, stackTrace: stackTrace);
  return Result.failure(failure);
}
