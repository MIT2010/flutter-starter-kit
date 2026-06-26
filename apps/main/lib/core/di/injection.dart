import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:feature_auth/feature_auth.dart';

Future<void> configureDependencies() async {
  // ── Core ──────────────────────────────────────────────────

  // Storage
  final secureStorage = SecureStorage();
  getIt.registerSingleton<SecureStorage>(secureStorage);

  // Auth local datasource — dibutuhkan sebelum ApiClient
  // karena ApiClient butuh getAccessToken callback
  final authLocalDataSource = AuthLocalDataSourceImpl(secureStorage);
  getIt.registerSingleton<AuthLocalDataSource>(authLocalDataSource);

  // Session manager
  final sessionManager = SessionManagerImpl(
    localDataSource: authLocalDataSource,
  );
  getIt.registerSingleton<SessionManagerImpl>(sessionManager);

  // Network
  getIt.registerSingleton<Connectivity>(Connectivity());

  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt<Connectivity>()));

  getIt.registerSingleton<ApiClient>(
    ApiClient(getAccessToken: () => sessionManager.getAccessToken()),
  );

  // ── Feature Auth ──────────────────────────────────────────

  // Datasources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: authLocalDataSource,
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerFactory(
    () => LoginWithEmailPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory(() => RequestOtpUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
}
