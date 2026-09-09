import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/auth_status_notifier.dart';
import 'app/di.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Logs every cubit's creation/state-transition/close app-wide — see
  // AppBlocObserver.
  Bloc.observer = getIt<AppBlocObserver>();
  // Deliberately not awaited: the app renders immediately while auth status
  // resolves in the background. The router's redirect guard must handle the
  // resulting `AuthStatus.unknown` window correctly — see app/router.dart.
  unawaited(getIt<AuthStatusNotifier>().resolve());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.isProduction
          ? 'Flutter Starter Kit'
          : 'Flutter Starter Kit (${AppConfig.flavor})',
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      routerConfig: appRouter,
    );
  }
}
