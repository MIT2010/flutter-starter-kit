// ignore_for_file: do_not_use_environment

/// Environment configuration yang dibaca dari --dart-define-from-file.
///
/// Cara pakai:
///   flutter run --dart-define-from-file=config/development.json
///   flutter build apk --dart-define-from-file=config/production.json
abstract class AppEnv {
  AppEnv._();

  // ── App ───────────────────────────────────────────────────
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Starter Kit',
  );

  // ── API ───────────────────────────────────────────────────
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api-dev.example.com',
  );

  // ── WebSocket (Laravel Reverb) ────────────────────────────
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://api-dev.example.com',
  );

  static const int wsPort = int.fromEnvironment(
    'WS_PORT',
    defaultValue: 6001,
  );

  static const String wsAppKey = String.fromEnvironment(
    'WS_APP_KEY',
    defaultValue: '',
  );

  static const String wsAuthEndpoint = String.fromEnvironment(
    'WS_AUTH_ENDPOINT',
    defaultValue: 'https://api-dev.example.com/broadcasting/auth',
  );

  // ── Monitoring ────────────────────────────────────────────
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // ── Feature flags ─────────────────────────────────────────
  static const bool enableLogs = bool.fromEnvironment(
    'ENABLE_LOGS',
    defaultValue: true,
  );

  static const bool enableDevtools = bool.fromEnvironment(
    'ENABLE_DEVTOOLS',
    defaultValue: false,
  );

  // ── Helpers ───────────────────────────────────────────────
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  static bool get hasSentry => sentryDsn.isNotEmpty;
}
