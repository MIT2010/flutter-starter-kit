part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status auth saat app pertama dibuka
final class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

/// Login dengan email dan password
final class AuthLoginWithEmailPasswordEvent extends AuthEvent {
  const AuthLoginWithEmailPasswordEvent({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Request OTP — untuk pola A (OTP sebagai login utama)
final class AuthRequestOtpEvent extends AuthEvent {
  const AuthRequestOtpEvent({required this.destination});

  final String destination;

  @override
  List<Object?> get props => [destination];
}

/// Verifikasi kode OTP
final class AuthVerifyOtpEvent extends AuthEvent {
  const AuthVerifyOtpEvent({required this.destination, required this.code});

  final String destination;
  final String code;

  @override
  List<Object?> get props => [destination, code];
}

/// Logout
final class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}
