import 'package:go_router/go_router.dart';

import '../core/logging/app_navigator_observer.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/example_feature/presentation/pages/example_feature_page.dart';
import 'auth_status_notifier.dart';
import 'di.dart';
// feature_brick:import_marker — do not remove; `mason make feature` inserts new feature screen imports above this line.

/// Single router instance for the whole app. New feature routes get added
/// as one more [GoRoute] entry in the list below — never a second
/// [GoRouter] instance or a parallel navigation mechanism.
final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: getIt<AuthStatusNotifier>(),
  observers: [getIt<AppNavigatorObserver>()],
  redirect: (context, state) {
    final authStatus = getIt<AuthStatusNotifier>().status;
    final isGoingToLogin = state.matchedLocation == '/login';

    // Auth check hasn't resolved yet — do NOT redirect. Treating "unknown"
    // the same as "unauthenticated" here would bounce an already-logged-in
    // user to /login on every cold start. See docs/decisions for the
    // incident this guards against.
    if (authStatus == AuthStatus.unknown) {
      return null;
    }

    if (authStatus == AuthStatus.unauthenticated && !isGoingToLogin) {
      return '/login';
    }

    if (authStatus == AuthStatus.authenticated && isGoingToLogin) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'example-feature',
      builder: (context, state) => const ExampleFeaturePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    // feature_brick:route_marker — do not remove; `mason make feature` inserts new GoRoute entries above this line.
  ],
);

/// Guard for a route that needs a typed [GoRouterState.extra].
///
/// Returns [fallback] (a redirect path) when `state.extra` is not a [T],
/// and `null` (no redirect) when it is. Put it in a route's `redirect` so
/// the `builder` can cast `state.extra` without a force-unwrap:
///
/// ```dart
/// GoRoute(
///   path: '/result',
///   name: 'result',
///   redirect: (context, state) => requireExtra<ResultArgs>(state, fallback: '/'),
///   builder: (context, state) => ResultPage(args: state.extra! as ResultArgs),
/// ),
/// ```
///
/// Why: `state.extra` is in-memory only and does not survive a full page
/// reload on Flutter Web, a deep link, or browser back/forward to a stale
/// history entry. A `builder` that does `state.extra! as ResultArgs` with
/// no guard throws uncaught inside `build`, where `errorBuilder` can't
/// catch it. The same applies to a path/query parameter a route can't
/// function without — validate it here and redirect instead of crashing.
String? requireExtra<T>(GoRouterState state, {required String fallback}) {
  return state.extra is T ? null : fallback;
}
