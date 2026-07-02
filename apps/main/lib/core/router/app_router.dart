import 'package:core/core.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final _authBloc = AuthBloc(
    loginWithEmailPassword: getIt<LoginWithEmailPasswordUseCase>(),
    requestOtp: getIt<RequestOtpUseCase>(),
    verifyOtp: getIt<VerifyOtpUseCase>(),
    logout: getIt<LogoutUseCase>(),
    getCurrentUser: getIt<GetCurrentUserUseCase>(),
    sessionManager: getIt<SessionManagerImpl>(),
  )..add(const AuthCheckStatusEvent());

  static final router = GoRouter(
    initialLocation: LoginPage.routePath,
    debugLogDiagnostics: true,
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: LoginPage.routePath,
        builder: (context, state) =>
            BlocProvider.value(value: _authBloc, child: const LoginPage()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _PlaceholderHome(),
      ),
    ],
  );

  static String? _authGuard(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isOnLogin = state.matchedLocation == LoginPage.routePath;

    return switch (authState) {
      AuthAuthenticated() => isOnLogin ? '/home' : null,
      AuthUnauthenticated() => isOnLogin ? null : LoginPage.routePath,
      _ => null, // AuthChecking & AuthLoading — tunggu
    };
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.dashboard.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berhasil login!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppRouter._authBloc.add(const AuthLogoutEvent());
              },
              child: Text(context.t.auth.logout),
            ),
          ],
        ),
      ),
    );
  }
}
