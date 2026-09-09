import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Logs every cubit's lifecycle app-wide — creation, each state
/// transition, and close — registered exactly once in `main.dart`
/// (`Bloc.observer = getIt<AppBlocObserver>()`), so every feature's cubit
/// gets this for free instead of each one needing its own log calls.
/// Previously this app only ever logged the network layer
/// ([LoggingInterceptor]); this is the same idea applied to app flow in
/// general.
///
/// Deliberately logs only class/state *type names*, never a state's own
/// field values — a freezed state's generated `toString()` can embed
/// sensitive data (an auth token, a base64 image), which must never
/// reach a log per the same redaction principle `LoggingInterceptor`
/// already enforces for request/response bodies.
@lazySingleton
class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._logger);

  final Logger _logger;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (AppConfig.enableAppFlowLogging) {
      _logger.d('${bloc.runtimeType} created');
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (AppConfig.enableAppFlowLogging) {
      _logger.d(
        '${bloc.runtimeType}: ${change.currentState.runtimeType} -> '
        '${change.nextState.runtimeType}',
      );
    }
  }

  // Deliberately NOT gated behind enableAppFlowLogging — an uncaught
  // exception escaping a cubit is a real bug, not routine flow noise, and
  // this app has no separate crash-reporting channel; suppressing it in
  // production (as enableAppFlowLogging does by default) would make it
  // invisible everywhere.
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      '${bloc.runtimeType}: uncaught error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (AppConfig.enableAppFlowLogging) {
      _logger.d('${bloc.runtimeType} closed');
    }
  }
}
