import 'package:equatable/equatable.dart';

/// Entity token autentikasi.
class AuthTokenEntity extends Equatable {
  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Sisa waktu sebelum token expired
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
