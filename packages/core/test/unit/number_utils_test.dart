import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toThousands', () {
    test('menambahkan separator titik tiap ribuan', () {
      expect(AppNumberUtils.toThousands(1000000), '1.000.000');
    });

    test('angka di bawah seribu tidak berubah', () {
      expect(AppNumberUtils.toThousands(999), '999');
    });

    test('mempertahankan bagian desimal dengan koma', () {
      expect(AppNumberUtils.toThousands(1234.5), '1.234,5');
    });
  });

  group('toRupiah', () {
    test('menambahkan prefix "Rp "', () {
      expect(AppNumberUtils.toRupiah(1000000), 'Rp 1.000.000');
    });
  });

  group('toPercent', () {
    test('default 0 desimal', () {
      expect(AppNumberUtils.toPercent(0.75), '75%');
    });

    test('bisa custom jumlah desimal', () {
      expect(AppNumberUtils.toPercent(0.756, decimals: 1), '75.6%');
    });
  });
}
