import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Provides the single shared [Logger] instance for the whole app.
///
/// Uses a compact [PrettyPrinter] (no method-count noise) suited to
/// interleaved network request/response logging — see
/// `core/network/interceptors/logging_interceptor.dart`, the only current
/// caller. Reuse this instance for any other logging rather than
/// constructing a separate `Logger()`.
@module
abstract class LoggingModule {
  @lazySingleton
  Logger get logger => Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
    ),
  );
}
