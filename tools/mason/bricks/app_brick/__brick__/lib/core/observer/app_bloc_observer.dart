import 'package:bloc/bloc.dart';
import 'package:core/core.dart';

/// Observer untuk semua BLoC di aplikasi.
/// Log setiap event, state change, dan error untuk debugging.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.debug('[BLoC] ${bloc.runtimeType} → $event');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error('[BLoC] ${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.debug('[BLoC] ${bloc.runtimeType} → ${change.nextState}');
  }
}
