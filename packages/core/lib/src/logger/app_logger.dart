import 'package:talker_flutter/talker_flutter.dart';

/// Wrapper di atas Talker untuk logging yang konsisten di seluruh app.
/// Gunakan ini, bukan print() langsung.
class AppLogger {
  AppLogger._();

  static late final Talker _talker;

  static void init({bool verbose = false}) {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        maxHistoryItems: 100,
      ),
    );
  }

  static void debug(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.debug(message, error, stackTrace);

  static void info(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.info(message, error, stackTrace);

  static void warning(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.warning(message, error, stackTrace);

  static void error(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.error(message, error, stackTrace);

  static void critical(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _talker.critical(message, error, stackTrace);

  /// Akses langsung ke instance Talker
  /// Dipakai untuk integrasi dengan Dio, BLoC observer, dst.
  static Talker get instance => _talker;
}
