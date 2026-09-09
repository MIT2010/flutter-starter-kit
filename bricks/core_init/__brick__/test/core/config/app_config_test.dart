import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/config/app_config.dart';

void main() {
  // These assert the defaults baked into AppConfig, which must match
  // config/development.json — this is what `flutter test` exercises with
  // no --dart-define-from-file flag at all. Run
  // `flutter test --dart-define-from-file=config/production.json` against
  // this same file to see these values (and therefore this test) actually
  // change — that's the real proof the --dart-define-from-file mechanism
  // works, not something this file alone can assert both sides of.
  test('defaults match config/development.json when no flavor is passed', () {
    expect(AppConfig.flavor, 'development');
    expect(AppConfig.apiBaseUrl, 'https://jsonplaceholder.typicode.com');
    expect(AppConfig.enableNetworkLogging, isTrue);
    expect(AppConfig.enableAppFlowLogging, isTrue);
    expect(AppConfig.isProduction, isFalse);
  });
}
