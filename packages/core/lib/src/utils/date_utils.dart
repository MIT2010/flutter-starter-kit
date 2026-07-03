/// Utility untuk formatting dan manipulasi tanggal.
class AppDateUtils {
  AppDateUtils._();

  /// Format: 12 Januari 2025
  static String toReadable(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format: 12 Jan 2025
  static String toShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format: 12/01/2025
  static String toNumeric(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Format durasi dalam detik menjadi MM:SS
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Apakah tanggal sudah lewat?
  static bool isPast(DateTime date) => date.isBefore(DateTime.now());

  /// Apakah tanggal belum tiba?
  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());
}
