import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toReadable', () {
    test('format "12 Januari 2025"', () {
      expect(AppDateUtils.toReadable(DateTime(2025, 1, 12)), '12 Januari 2025');
    });
  });

  group('toShort', () {
    test('format "12 Jan 2025"', () {
      expect(AppDateUtils.toShort(DateTime(2025, 1, 12)), '12 Jan 2025');
    });
  });

  group('toNumeric', () {
    test('format "12/01/2025" dengan padding nol', () {
      expect(AppDateUtils.toNumeric(DateTime(2025, 1, 12)), '12/01/2025');
    });
  });

  group('formatDuration', () {
    test('format MM:SS untuk durasi di bawah 1 jam', () {
      expect(
        AppDateUtils.formatDuration(const Duration(minutes: 5, seconds: 30)),
        '05:30',
      );
    });

    test('menit di-mod 60 untuk durasi 1 jam ke atas', () {
      // Fungsi ini hanya menampilkan MM:SS, bukan HH:MM:SS — jadi durasi
      // di atas 1 jam "kehilangan" info jamnya di output, sesuai
      // implementasi asli.
      expect(
        AppDateUtils.formatDuration(
          const Duration(hours: 1, minutes: 5, seconds: 9),
        ),
        '05:09',
      );
    });
  });

  group('isPast & isFuture', () {
    test('isPast true untuk tanggal di masa lalu', () {
      expect(AppDateUtils.isPast(DateTime(2000, 1, 1)), true);
    });

    test('isFuture true untuk tanggal di masa depan', () {
      final farFuture = DateTime.now().add(const Duration(days: 3650));
      expect(AppDateUtils.isFuture(farFuture), true);
    });

    test('isPast false untuk tanggal di masa depan', () {
      final farFuture = DateTime.now().add(const Duration(days: 3650));
      expect(AppDateUtils.isPast(farFuture), false);
    });
  });
}
