import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toTitleCase', () {
    test('mengkapitalkan setiap kata', () {
      expect(AppStringUtils.toTitleCase('hello world'), 'Hello World');
    });

    test('menormalkan huruf besar-kecil campuran', () {
      expect(AppStringUtils.toTitleCase('hELLO wORLD'), 'Hello World');
    });

    test('string kosong tetap kosong', () {
      expect(AppStringUtils.toTitleCase(''), '');
    });
  });

  group('capitalize', () {
    test('hanya huruf pertama yang dikapitalkan', () {
      expect(AppStringUtils.capitalize('hello world'), 'Hello world');
    });

    test('string kosong tetap kosong', () {
      expect(AppStringUtils.capitalize(''), '');
    });
  });

  group('truncate', () {
    test('memotong dan menambahkan "..." jika melebihi maxLength', () {
      expect(AppStringUtils.truncate('Hello World', 5), 'Hello...');
    });

    test('tidak berubah jika tidak melebihi maxLength', () {
      expect(AppStringUtils.truncate('Hi', 5), 'Hi');
    });

    test('tidak berubah jika persis sama dengan maxLength', () {
      expect(AppStringUtils.truncate('Hello', 5), 'Hello');
    });
  });

  group('isValidEmail', () {
    test('true untuk email valid', () {
      expect(AppStringUtils.isValidEmail('test@example.com'), true);
    });

    test('false untuk string tanpa @', () {
      expect(AppStringUtils.isValidEmail('invalid'), false);
    });

    test('false untuk domain tanpa nama sebelum titik', () {
      expect(AppStringUtils.isValidEmail('test@.com'), false);
    });
  });

  group('isValidPhone', () {
    test('true untuk nomor diawali 0', () {
      expect(AppStringUtils.isValidPhone('081234567890'), true);
    });

    test('true untuk nomor diawali +62', () {
      expect(AppStringUtils.isValidPhone('+6281234567890'), true);
    });

    test('false untuk nomor tanpa prefix yang valid', () {
      expect(AppStringUtils.isValidPhone('123456'), false);
    });
  });

  group('alphanumericOnly', () {
    test('menghapus semua karakter selain huruf dan angka', () {
      expect(AppStringUtils.alphanumericOnly('Hello, World! 123'), 'HelloWorld123');
    });
  });
}
