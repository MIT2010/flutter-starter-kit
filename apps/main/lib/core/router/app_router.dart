import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Router utama aplikasi.
/// Routes akan ditambahkan saat tiap feature diimplementasikan.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _PlaceholderHome(),
      ),
    ],
  );
}

/// Placeholder sementara — akan diganti dengan feature_dashboard
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Flutter Starter Kit\nReady!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
