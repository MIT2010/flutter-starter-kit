import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Applied automatically to every test file under `test/`.
///
/// Without this, `flutter_test` renders all text with a block-glyph
/// fallback font — golden tests would pass even if typography (weight,
/// size, family) were visibly broken in the real app. This loads the
/// app's real fonts (declared in pubspec.yaml -> flutter -> fonts) from
/// FontManifest.json before any test runs.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(loadAppFonts);
  await testMain();
}

Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontManifest = await rootBundle.loadStructuredData<List<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string) as List<dynamic>,
  );

  for (final dynamic entry in fontManifest) {
    final font = entry as Map<String, dynamic>;
    final fontLoader = FontLoader(font['family'] as String);
    for (final dynamic variant in font['fonts'] as List<dynamic>) {
      final asset = (variant as Map<String, dynamic>)['asset'] as String;
      fontLoader.addFont(rootBundle.load(asset));
    }
    await fontLoader.load();
  }
}
