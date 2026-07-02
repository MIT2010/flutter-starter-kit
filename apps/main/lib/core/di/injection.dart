import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:feature_assessment/feature_assessment.dart';
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
    ApiClient(
      getAccessToken: () => sessionManager.getAccessToken(),
      // Refresh token otomatis saat request gagal dengan 401.
      // Lookup AuthRepository lewat getIt (bukan reference langsung) karena
      // repository itu sendiri baru diregistrasi belakangan dan butuh
      // ApiClient ini — closure ini baru dieksekusi saat ada 401 di runtime,
      // jauh setelah semua dependency selesai didaftarkan.
      refreshToken: () async {
        final storedRefreshToken = await sessionManager.getRefreshToken();
        if (storedRefreshToken == null) return false;

        final result = await getIt<RefreshTokenUseCase>()(storedRefreshToken);
        if (result.isLeft()) {
          await sessionManager.clearSession();
          return false;
        }
        return true;
      },
    ),
  );

  // ── Offline Queue ─────────────────────────────────────────

  // Assessment queue — retry SELAMANYA, data tidak boleh hilang
  final assessmentQueueManager = QueueSyncManager(
    storage: QueueStorage('queue_assessment_answers'),
    networkInfo: getIt<NetworkInfo>(),
    retryPolicy: const RetryPolicy.unlimited(),
  );
  assessmentQueueManager.registerHandler(
    AnswerQueueHandler(getIt<ApiClient>()),
  );
  assessmentQueueManager.startAutoSync();
  getIt.registerSingleton<QueueSyncManager>(
    assessmentQueueManager,
    instanceName: 'assessmentQueue',
  );

  // Generic queue — retry maksimal 5x, untuk operasi non-kritis
  // Belum ada handler terdaftar karena belum ada fitur (profile, dll)
  // yang pakai queue ini. Saat fitur tsb diimplementasikan, panggil
  // genericQueueManager.registerHandler(...) di sini untuk tiap tipe
  // operasinya — item yang di-enqueue tanpa handler akan gagal terus.
  final genericQueueManager = QueueSyncManager(
    storage: QueueStorage('queue_generic_mutations'),
    networkInfo: getIt<NetworkInfo>(),
    retryPolicy: const RetryPolicy.limited(maxAttempts: 5),
  );
  genericQueueManager.startAutoSync();
  getIt.registerSingleton<QueueSyncManager>(
    genericQueueManager,
    instanceName: 'genericQueue',
  );

  // Answer submission service — pakai assessment queue
  getIt.registerSingleton<AnswerSubmissionService>(
    AnswerSubmissionService(assessmentQueueManager),
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
  getIt.registerFactory(() => RefreshTokenUseCase(getIt<AuthRepository>()));
}
