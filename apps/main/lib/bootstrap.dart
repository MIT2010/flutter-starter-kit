import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'core/observer/app_bloc_observer.dart';
import 'app.dart';

Future<void> bootstrap({AppFlavor flavor = AppFlavor.development}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientasi hanya portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Logger
  AppLogger.init(verbose: flavor.isDevelopment);

  // 2. Security — RASP engine, jalan sebelum apapun
  await AppSecurityGuard.init();

  // 3. BLoC observer
  Bloc.observer = const AppBlocObserver();

  // 4. Storage
  await AppStorage.init();

  // 5. Dependency injection
  await configureDependencies();

  // 6. Localization — deteksi locale device, load terjemahan yang aktif
  await LocaleSettings.useDeviceLocale();

  // 7. Tangkap Flutter errors
  FlutterError.onError = (details) {
    AppLogger.error(
      'Flutter error',
      details.exception,
      details.stack,
    );
  };

  runApp(TranslationProvider(child: const App()));
}
