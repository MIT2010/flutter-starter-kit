/// Compile-time environment configuration.
///
/// Populated via `--dart-define-from-file=config/<flavor>.json` (see the
/// `config/` directory at the repo root and ADR-0009) — never hand-edit a
/// flavor's values into source. Every field has a default matching
/// `config/development.json`, so plain `flutter run`/`flutter test` (no
/// flags at all) still work.
class AppConfig {
  const AppConfig._();

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  static const bool enableNetworkLogging = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGGING',
    defaultValue: true,
  );

  /// Gates [AppBlocObserver] (cubit creation/state-transition/close logs)
  /// and the router's navigation logging — the app-flow counterpart to
  /// [enableNetworkLogging], off by default in production for the same
  /// reason (routine noise, not a redaction concern — neither logs full
  /// state/argument content, only type names, so there's nothing sensitive
  /// gated here). Uncaught cubit errors log regardless of this flag; see
  /// AppBlocObserver.onError.
  static const bool enableAppFlowLogging = bool.fromEnvironment(
    'ENABLE_APP_FLOW_LOGGING',
    defaultValue: true,
  );

  static bool get isProduction => flavor == 'production';
}
