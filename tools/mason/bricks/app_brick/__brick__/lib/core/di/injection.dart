import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';

Future<void> configureDependencies() async {
  // ── Core ──────────────────────────────────────────────────

  getIt.registerSingleton<SecureStorage>(SecureStorage());

  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt<Connectivity>()));

  getIt.registerSingleton<ApiClient>(
    ApiClient(
      // Belum ada fitur auth — token getter sementara return null.
      // Update setelah menambah fitur auth (lihat feature_brick lewat
      // `melos run feature:new`), lengkapi dengan `refreshToken` callback
      // mengikuti pola di apps/main/lib/core/di/injection.dart.
      getAccessToken: () async => null,
    ),
  );

  // Tambahkan registrasi fitur di sini, section baru per fitur — lihat
  // pola di apps/main/lib/core/di/injection.dart (datasource -> repository
  // -> use case, lewat getIt.registerSingleton/registerFactory).
}
