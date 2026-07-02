import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('default messages', () {
    test('NetworkFailure', () {
      expect(const NetworkFailure().message, 'Tidak ada koneksi internet');
    });

    test('UnauthorizedFailure', () {
      expect(
        const UnauthorizedFailure().message,
        'Sesi kamu telah berakhir, silakan login kembali',
      );
    });

    test('NotFoundFailure', () {
      expect(const NotFoundFailure().message, 'Data tidak ditemukan');
    });

    test('UnknownFailure', () {
      expect(
        const UnknownFailure().message,
        'Terjadi kesalahan, silakan coba lagi',
      );
    });
  });

  group('equality (Equatable)', () {
    test('dua Failure sederhana dengan message sama dianggap sama', () {
      expect(const NetworkFailure(), const NetworkFailure());
      expect(
        const CacheFailure(message: 'gagal baca cache'),
        const CacheFailure(message: 'gagal baca cache'),
      );
    });

    test('ServerFailure ikut membandingkan statusCode', () {
      expect(
        const ServerFailure(message: 'error', statusCode: 500),
        const ServerFailure(message: 'error', statusCode: 500),
      );
      expect(
        const ServerFailure(message: 'error', statusCode: 500),
        isNot(equals(const ServerFailure(message: 'error', statusCode: 503))),
      );
    });

    test('ValidationFailure ikut membandingkan messages', () {
      expect(
        const ValidationFailure(
          message: 'gagal',
          messages: ['a', 'b'],
        ),
        const ValidationFailure(message: 'gagal', messages: ['a', 'b']),
      );
      expect(
        const ValidationFailure(message: 'gagal', messages: ['a']),
        isNot(
          equals(const ValidationFailure(message: 'gagal', messages: ['b'])),
        ),
      );
    });

    test('Failure dengan tipe berbeda tidak pernah sama meski message sama', () {
      expect(
        const NetworkFailure(message: 'x'),
        isNot(equals(const UnknownFailure(message: 'x'))),
      );
    });
  });
}
