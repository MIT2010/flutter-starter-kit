import 'dart:io';

import 'package:mason/mason.dart';

const _importMarker = '// feature_brick:import_marker';
const _routeMarker = '// feature_brick:route_marker';

void run(HookContext context) {
  final featureName = context.vars['feature_name'].toString();
  final snake = featureName.snakeCase;
  final pascal = featureName.pascalCase;

  final routerFile = File('lib/app/router.dart');
  if (!routerFile.existsSync()) {
    context.logger.warn(
      'lib/app/router.dart not found — skipping route wiring. '
      'Add the route for ${pascal}Page manually.',
    );
    return;
  }

  var content = routerFile.readAsStringSync();

  if (!content.contains(_importMarker) || !content.contains(_routeMarker)) {
    context.logger.warn(
      'lib/app/router.dart is missing the feature_brick markers — skipping '
      'automatic route wiring. Add the import and GoRoute for '
      '${pascal}Page manually, and restore the markers to fix this for '
      'next time.',
    );
    return;
  }

  final importLine =
      "import '../features/$snake/presentation/pages/${snake}_page.dart';\n$_importMarker";
  // `name:` is required — AppNavigatorObserver logs route.settings.name, and
  // go_router only populates it from a GoRoute's own `name:` field. Without
  // it every navigation involving this route logs as "unnamed".
  final routeName = featureName.paramCase;
  final routeEntry =
      "    GoRoute(\n"
      "      path: '/$snake',\n"
      "      name: '$routeName',\n"
      "      builder: (context, state) => const ${pascal}Page(),\n"
      "    ),\n"
      "    $_routeMarker";

  content = content.replaceFirst(_importMarker, importLine);
  content = content.replaceFirst('    $_routeMarker', routeEntry);

  routerFile.writeAsStringSync(content);

  context.logger.success('Wired /$snake -> ${pascal}Page into lib/app/router.dart');
}
