// ignore_for_file: do_not_use_environment

/// Environment configuration yang dibaca dari --dart-define saat build.
///
/// Cara pakai saat run/build:
///   flutter run --dart-define=ENV=development --dart-define=BASE_URL=https://api-dev.example.com
///   flutter build apk --dart-define=ENV=production --dart-define=BASE_URL=https://api.example.com
abstract class AppEnv {
  AppEnv._();

  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api-dev.example.com',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://api-dev.example.com',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
}
