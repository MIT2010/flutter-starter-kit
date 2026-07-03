/// Utility untuk manipulasi String.
class AppStringUtils {
  AppStringUtils._();

  /// "hello world" → "Hello World"
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// "hello world" → "Hello world"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Potong teks jika melebihi maxLength, tambahkan "..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Cek apakah string adalah email yang valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Cek apakah string adalah nomor telepon valid (format Indonesia)
  static bool isValidPhone(String phone) {
    return RegExp(r'^(\+62|62|0)[0-9]{8,12}$').hasMatch(phone);
  }

  /// Hapus semua karakter selain huruf dan angka
  static String alphanumericOnly(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }
}
