part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal — sedang mengecek status auth
final class AuthChecking extends AuthState {}

/// User sudah terautentikasi
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// User belum login
final class AuthUnauthenticated extends AuthState {}

/// Sedang proses — login, request OTP, verify OTP, logout
final class AuthLoading extends AuthState {}

/// OTP berhasil dikirim — UI perlu tampilkan form input OTP
final class AuthOtpSent extends AuthState {
  const AuthOtpSent(this.otp);

  final OtpEntity otp;

  @override
  List<Object?> get props => [otp];
}

/// Terjadi error
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
