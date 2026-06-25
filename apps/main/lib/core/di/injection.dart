import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

/// Setup dependency injection.
/// Dependencies akan didaftarkan di sini saat tiap feature diimplementasikan.
Future<void> configureDependencies() async {
  // Core services
  getIt.registerLazySingleton<GetIt>(() => getIt);

  // Dependencies lain akan ditambahkan di sini
}
