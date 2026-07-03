import 'package:equatable/equatable.dart';

/// Base class untuk semua kegagalan di domain layer.
/// Failure adalah "bahasa" yang dimengerti domain — bukan Exception teknis.
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Tidak ada koneksi internet
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}

/// Server mengembalikan error
class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Token expired atau tidak valid
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Sesi kamu telah berakhir, silakan login kembali',
  });
}

/// Data tidak ditemukan
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Data tidak ditemukan'});
}

/// Masalah di local storage
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Validasi input gagal — bisa punya banyak pesan error
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.messages = const []});

  /// Untuk kasus backend kirim "messages" berupa list
  final List<String> messages;

  @override
  List<Object?> get props => [message, messages];
}

/// Error yang tidak diketahui penyebabnya
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Terjadi kesalahan, silakan coba lagi',
  });
}
