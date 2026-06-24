/// Utility untuk formatting angka.
class AppNumberUtils {
  AppNumberUtils._();

  /// Format angka dengan separator ribuan
  /// 1000000 → "1.000.000"
  static String toThousands(num number) {
    final parts = number.toString().split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return parts.length > 1 ? '$intPart,${parts[1]}' : intPart;
  }

  /// Format ke Rupiah
  /// 1000000 → "Rp 1.000.000"
  static String toRupiah(num amount) {
    return 'Rp ${toThousands(amount)}';
  }

  /// Format ke persentase
  /// 0.75 → "75%"
  static String toPercent(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
}
