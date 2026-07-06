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

  // ReverbManager — sebelumnya diekspor lengkap dari core_network (connect,
  // subscribe public/private channel, auto-resubscribe saat reconnect) tapi
  // tidak pernah didaftarkan ke DI sama sekali, jadi tidak ada cara
  // mengaksesnya lewat getIt. Didaftarkan di sini sebagai singleton supaya
  // tersedia untuk fitur manapun yang butuh realtime (mis. feature_notification
  // saat diimplementasikan nanti).
  //
  // Sengaja TIDAK memanggil .connect() di sini: sebelum ada consumer yang
  // benar-benar subscribe ke sebuah channel, membuka koneksi WebSocket cuma
  // buang-buang resource (dan bisa gagal diam-diam kalau WS_APP_KEY belum
  // diisi di config/*.json). Panggil connect() dari fitur yang memakainya,
  // saat fitur itu benar-benar butuh koneksi realtime.
  // AppEnv.wsUrl adalah URL lengkap (mis. "wss://api-dev.example.com"),
  // tapi ReverbManager/PusherChannelsOptions.fromHost butuh hostname polos
  // tanpa skema (skema "ws"/"wss" ditentukan terpisah di dalam ReverbManager
  // sendiri) — ketahuan sekarang karena baru kali ini benar-benar dipakai.
  // Uri.parse(...).host aman dipakai untuk kedua kasus (dengan atau tanpa
  // skema di depannya).
  final wsHost = Uri.parse(AppEnv.wsUrl).host.isNotEmpty
      ? Uri.parse(AppEnv.wsUrl).host
      : AppEnv.wsUrl;

  getIt.registerSingleton<ReverbManager>(
    ReverbManager(
      host: wsHost,
      port: AppEnv.wsPort,
      appKey: AppEnv.wsAppKey,
      getAccessToken: () => sessionManager.getAccessToken(),
      authEndpoint: AppEnv.wsAuthEndpoint,
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

  // ── Feature Assessment ────────────────────────────────────

  // Datasources
  getIt.registerSingleton<AssessmentRemoteDataSource>(
    AssessmentRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerSingleton<AssessmentLocalDataSource>(
    AssessmentLocalDataSourceImpl(HiveStorage<String>('assessment_cache')),
  );

  // Repository
  getIt.registerSingleton<AssessmentRepository>(
    AssessmentRepositoryImpl(
      remoteDataSource: getIt<AssessmentRemoteDataSource>(),
      localDataSource: getIt<AssessmentLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerFactory(
    () => GetAssessmentUseCase(getIt<AssessmentRepository>()),
  );
  getIt.registerFactory(
    () => StartAssessmentSessionUseCase(getIt<AssessmentRepository>()),
  );
  getIt.registerFactory(
    () => GetActiveSessionUseCase(getIt<AssessmentRepository>()),
  );
  getIt.registerFactory(
    () => SaveSessionProgressUseCase(getIt<AssessmentRepository>()),
  );
  getIt.registerFactory(
    () => CompleteAssessmentSessionUseCase(getIt<AssessmentRepository>()),
  );
  getIt.registerFactory(
    () => SubmitAnswerUseCase(getIt<AnswerSubmissionService>()),
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
