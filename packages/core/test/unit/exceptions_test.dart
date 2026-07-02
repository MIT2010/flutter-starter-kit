import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('default values', () {
    test('NetworkException', () {
      const e = NetworkException();
      expect(e.message, 'Tidak dapat terhubung ke server');
      expect(e.statusCode, isNull);
    });

    test('UnauthorizedException', () {
      const e = UnauthorizedException();
      expect(e.message, 'Unauthorized');
      expect(e.statusCode, 401);
    });

    test('NotFoundException', () {
      const e = NotFoundException();
      expect(e.message, 'Tidak ditemukan');
      expect(e.statusCode, 404);
    });

    test('ValidationException default statusCode 422 dan messages kosong', () {
      const e = ValidationException(message: 'gagal validasi');
      expect(e.statusCode, 422);
      expect(e.messages, isEmpty);
    });

    test('ValidationException bisa membawa banyak pesan', () {
      const e = ValidationException(
        message: 'gagal validasi',
        messages: ['email wajib diisi', 'password wajib diisi'],
      );
      expect(e.messages, ['email wajib diisi', 'password wajib diisi']);
    });
  });

  group('toString', () {
    test('mencantumkan message dan statusCode', () {
      const e = ServerException(message: 'Internal error', statusCode: 500);
      expect(e.toString(), 'AppException: Internal error (statusCode: 500)');
    });

    test('statusCode null tetap tercetak sebagai "null"', () {
      const e = AppException(message: 'unknown');
      expect(e.toString(), 'AppException: unknown (statusCode: null)');
    });
  });
}
