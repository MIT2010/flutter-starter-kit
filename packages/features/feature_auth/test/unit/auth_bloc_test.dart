import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_auth/shared_auth.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginWithEmailPasswordUseCase,
  RequestOtpUseCase,
  VerifyOtpUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  SessionManagerImpl,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginWithEmailPasswordUseCase mockLogin;
  late MockRequestOtpUseCase mockRequestOtp;
  late MockVerifyOtpUseCase mockVerifyOtp;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockSessionManagerImpl mockSessionManager;

  const tUser = UserEntity(id: '1', name: 'Test User', email: 'test@email.com');

  final tToken = AuthTokenEntity(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  final tOtp = OtpEntity(
    destination: '08123456789',
    expiresIn: 300,
    requestedAt: DateTime.now(),
  );

  setUp(() {
    mockLogin = MockLoginWithEmailPasswordUseCase();
    mockRequestOtp = MockRequestOtpUseCase();
    mockVerifyOtp = MockVerifyOtpUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockSessionManager = MockSessionManagerImpl();

    // Provide dummy values untuk semua Either types
    provideDummy<Either<Failure, AuthTokenEntity>>(Either.right(tToken));
    provideDummy<Either<Failure, UserEntity>>(Either.right(tUser));
    provideDummy<Either<Failure, OtpEntity>>(Either.right(tOtp));
    provideDummy<Either<Failure, Unit>>(Either.right(unit));

    // Stub SessionManagerImpl — gunakan thenReturn bukan when untuk getter
    when(
      mockSessionManager.currentStatus,
    ).thenReturn(AuthStatus.unauthenticated);
    when(mockSessionManager.initialize()).thenAnswer((_) async {});
    when(
      mockSessionManager.saveSession(
        token: anyNamed('token'),
        user: anyNamed('user'),
      ),
    ).thenAnswer((_) async {});
    when(mockSessionManager.clearSession()).thenAnswer((_) async {});

    authBloc = AuthBloc(
      loginWithEmailPassword: mockLogin,
      requestOtp: mockRequestOtp,
      verifyOtp: mockVerifyOtp,
      logout: mockLogout,
      getCurrentUser: mockGetCurrentUser,
      sessionManager: mockSessionManager,
    );
  });

  tearDown(() => authBloc.close());

  group('AuthCheckStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emit [AuthUnauthenticated] saat tidak ada session',
      build: () {
        when(
          mockSessionManager.currentStatus,
        ).thenReturn(AuthStatus.unauthenticated);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckStatusEvent()),
      expect: () => [AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emit [AuthAuthenticated] saat session valid',
      build: () {
        when(
          mockSessionManager.currentStatus,
        ).thenReturn(AuthStatus.authenticated);
        when(mockGetCurrentUser()).thenAnswer((_) async => Either.right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckStatusEvent()),
      expect: () => [const AuthAuthenticated(tUser)],
    );
  });

  group('AuthLoginWithEmailPasswordEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthAuthenticated] saat login berhasil (Pola B) — '
      'sebelumnya bug: berhenti di AuthUnauthenticated meski token valid, '
      'lihat komentar perbaikan di auth_bloc.dart',
      build: () {
        when(mockLogin(any)).thenAnswer((_) async => Either.right(tToken));
        when(mockGetCurrentUser()).thenAnswer((_) async => Either.right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginWithEmailPasswordEvent(
          email: 'test@email.com',
          password: 'password123',
        ),
      ),
      expect: () => [AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(
          mockSessionManager.saveSession(
            token: anyNamed('token'),
            user: anyNamed('user'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthError] saat login gagal',
      build: () {
        when(
          mockLogin(any),
        ).thenAnswer((_) async => Either.left(const UnauthorizedFailure()));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginWithEmailPasswordEvent(
          email: 'wrong@email.com',
          password: 'wrong',
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('Sesi kamu telah berakhir, silakan login kembali'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthError] kalau token didapat tapi gagal '
      'mengambil data user setelahnya',
      build: () {
        when(mockLogin(any)).thenAnswer((_) async => Either.right(tToken));
        when(mockGetCurrentUser()).thenAnswer(
          (_) async => Either.left(const ServerFailure(message: 'gagal ambil user')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginWithEmailPasswordEvent(
          email: 'test@email.com',
          password: 'password123',
        ),
      ),
      expect: () => [AuthLoading(), const AuthError('gagal ambil user')],
    );
  });

  group('AuthRequestOtpEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthOtpSent] saat OTP berhasil dikirim',
      build: () {
        when(mockRequestOtp(any)).thenAnswer((_) async => Either.right(tOtp));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthRequestOtpEvent(destination: '08123456789')),
      expect: () => [AuthLoading(), AuthOtpSent(tOtp)],
    );
  });

  group('AuthVerifyOtpEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthAuthenticated] saat OTP valid',
      build: () {
        when(mockVerifyOtp(any)).thenAnswer((_) async => Either.right(tToken));
        when(mockGetCurrentUser()).thenAnswer((_) async => Either.right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthVerifyOtpEvent(destination: '08123456789', code: '123456'),
      ),
      expect: () => [AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(
          mockSessionManager.saveSession(
            token: anyNamed('token'),
            user: anyNamed('user'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthError] saat OTP salah',
      build: () {
        when(mockVerifyOtp(any)).thenAnswer(
          (_) async =>
              Either.left(const ServerFailure(message: 'Kode OTP tidak valid')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthVerifyOtpEvent(destination: '08123456789', code: '000000'),
      ),
      expect: () => [AuthLoading(), const AuthError('Kode OTP tidak valid')],
    );
  });

  group('AuthLogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emit [AuthLoading, AuthUnauthenticated] saat logout',
      build: () {
        when(mockLogout()).thenAnswer((_) async => Either.right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutEvent()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
      verify: (_) {
        verify(mockSessionManager.clearSession());
      },
    );
  });
}
