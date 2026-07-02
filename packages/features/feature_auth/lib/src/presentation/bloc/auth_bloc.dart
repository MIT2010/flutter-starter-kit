import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_auth/shared_auth.dart';
import '../../domain/entities/otp_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_password_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../session/session_manager_impl.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginWithEmailPassword,
    required this._requestOtp,
    required this._verifyOtp,
    required this._logout,
    required this._getCurrentUser,
    required this._sessionManager,
  }) : super(AuthChecking()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginWithEmailPasswordEvent>(_onLoginWithEmailPassword);
    on<AuthRequestOtpEvent>(_onRequestOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);
  }

  final LoginWithEmailPasswordUseCase _loginWithEmailPassword;
  final RequestOtpUseCase _requestOtp;
  final VerifyOtpUseCase _verifyOtp;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final SessionManagerImpl _sessionManager;

  /// Cek status saat app dibuka
  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionManager.initialize();

    if (_sessionManager.currentStatus == AuthStatus.authenticated) {
      // Ambil data user terbaru dari API
      final result = await _getCurrentUser();
      result.fold((failure) => emit(AuthUnauthenticated()), (user) {
        emit(AuthAuthenticated(user));
      });
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Login dengan email dan password (Pola B — lanjut ke OTP)
  Future<void> _onLoginWithEmailPassword(
    AuthLoginWithEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginWithEmailPassword(
      LoginWithEmailPasswordParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      // Pola B: setelah login berhasil, backend trigger OTP
      // UI akan navigasi ke OTP screen setelah state ini
      (token) => emit(AuthUnauthenticated()),
    );
  }

  /// Request OTP (Pola A — OTP sebagai login utama)
  Future<void> _onRequestOtp(
    AuthRequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _requestOtp(
      RequestOtpParams(destination: event.destination),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (otp) => emit(AuthOtpSent(otp)),
    );
  }

  /// Verifikasi OTP — sama untuk Pola A dan B
  Future<void> _onVerifyOtp(
    AuthVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _verifyOtp(
      VerifyOtpParams(destination: event.destination, code: event.code),
    );

    await result.fold((failure) async => emit(AuthError(failure.message)), (
      token,
    ) async {
      // Setelah OTP verified, ambil data user
      final userResult = await _getCurrentUser();
      await userResult.fold(
        (failure) async => emit(AuthError(failure.message)),
        (user) async {
          await _sessionManager.saveSession(token: token, user: user);
          emit(AuthAuthenticated(user));
        },
      );
    });
  }

  /// Logout
  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _logout();
    await _sessionManager.clearSession();
    emit(AuthUnauthenticated());
  }
}
