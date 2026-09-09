import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Logs every screen navigation (push/pop/replace/remove) app-wide.
/// Attached to the single [GoRouter] instance via its `observers:` list —
/// see `app/router.dart`. Relies on every [GoRoute] having a `name:` so
/// `route.settings.name` is populated (go_router propagates it onto the
/// underlying [Route]); a route with no name logs as `unnamed` rather than
/// silently omitting the log line.
@lazySingleton
class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._logger);

  final Logger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', from: previousRoute, to: route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', from: route, to: previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _log('replace', from: oldRoute, to: newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('remove', from: route, to: previousRoute);
  }

  void _log(String action, {required Route<dynamic>? from, Route<dynamic>? to}) {
    if (!AppConfig.enableAppFlowLogging) return;
    _logger.d('Navigation $action: ${_name(from)} -> ${_name(to)}');
  }

  String _name(Route<dynamic>? route) => route?.settings.name ?? 'unnamed';
}
