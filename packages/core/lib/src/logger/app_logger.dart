import 'package:talker_flutter/talker_flutter.dart';

/// Wrapper di atas Talker untuk logging yang konsisten di seluruh app.
/// Gunakan ini, bukan print() langsung.
class AppLogger {
  AppLogger._();

  static late final Talker _talker;
  static void Function(dynamic error, StackTrace? stackTrace)? _errorReporter;

  static void init({bool verbose = false}) {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        maxHistoryItems: 100,
      ),
    );
  }

  /// Daftarkan sink error eksternal (mis. Sentry) — dipanggil setiap kali
  /// [error] atau [critical] dipakai. core sengaja tidak punya dependency
  /// langsung ke provider crash-reporting manapun; wiring-nya dilakukan
  /// di app layer (lihat apps/main/lib/bootstrap.dart).
  static void registerErrorReporter(
    void Function(dynamic error, StackTrace? stackTrace) reporter,
  ) {
    _errorReporter = reporter;
  }

  static void debug(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.debug(message, error, stackTrace);

  static void info(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.info(message, error, stackTrace);

  static void warning(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.warning(message, error, stackTrace);

  static void error(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
    _errorReporter?.call(error ?? message, stackTrace);
  }

  static void critical(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _talker.critical(message, error, stackTrace);
    _errorReporter?.call(error ?? message, stackTrace);
  }

  /// Akses langsung ke instance Talker
  /// Dipakai untuk integrasi dengan Dio, BLoC observer, dst.
  static Talker get instance => _talker;
}
