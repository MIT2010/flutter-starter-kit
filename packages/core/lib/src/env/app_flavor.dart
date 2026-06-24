/// Flavor aplikasi — menentukan environment yang aktif.
enum AppFlavor {
  development,
  staging,
  production;

  bool get isDevelopment => this == AppFlavor.development;
  bool get isStaging => this == AppFlavor.staging;
  bool get isProduction => this == AppFlavor.production;
}
