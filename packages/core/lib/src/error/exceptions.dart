/// Base class untuk semua exception di data layer.
/// Exception dilempar oleh datasource, ditangkap oleh repository,
/// lalu dikonversi menjadi Failure sebelum naik ke domain layer.
class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Masalah koneksi jaringan
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Tidak dapat terhubung ke server',
  });
}

/// Server mengembalikan response error
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Token tidak valid atau expired
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
  });
}

/// Resource tidak ditemukan
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Tidak ditemukan',
    super.statusCode = 404,
  });
}

/// Validasi gagal — bisa punya banyak pesan
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    this.messages = const [],
    super.statusCode = 422,
  });

  final List<String> messages;
}

/// Masalah baca/tulis local storage
class CacheException extends AppException {
  const CacheException({required super.message});
}
