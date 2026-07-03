import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
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

// Tambahkan route fitur di sini — lihat pola di
// apps/main/lib/core/router/app_router.dart.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{name.titleCase()}}')),
      body: const Center(child: Text('Belum ada fitur — mulai dengan `melos run feature:new`')),
    );
  }
}
