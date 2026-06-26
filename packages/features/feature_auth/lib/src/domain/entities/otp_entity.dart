import 'package:equatable/equatable.dart';

/// Entity untuk hasil request OTP.
/// Berisi informasi yang dibutuhkan UI untuk countdown timer
/// dan hint nomor tujuan OTP.
class OtpEntity extends Equatable {
  const OtpEntity({
    required this.destination,
    required this.expiresIn,
    required this.requestedAt,
  });

  /// Tujuan OTP — bisa nomor HP atau email (sebagian disensor)
  /// Contoh: "08**********23" atau "u***@example.com"
  final String destination;

  /// Durasi OTP valid dalam detik
  final int expiresIn;

  /// Waktu OTP dikirim — untuk hitung sisa waktu
  final DateTime requestedAt;

  /// Waktu OTP akan expired
  DateTime get expiresAt => requestedAt.add(Duration(seconds: expiresIn));

  /// Apakah OTP sudah expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Sisa waktu dalam detik
  int get remainingSeconds {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  List<Object?> get props => [destination, expiresIn, requestedAt];
}
