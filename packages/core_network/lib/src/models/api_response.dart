/// Representasi internal response API yang sudah dinormalisasi.
/// Semua variasi format backend dikonversi ke bentuk ini oleh ResponseParser.
class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.message,
    this.messages = const [],
    this.data,
  });

  final bool isSuccess;

  /// Pesan utama dari backend
  final String message;

  /// Diisi jika backend mengirim error dalam bentuk list (field "messages")
  final List<String> messages;

  final T? data;

  /// Ambil semua pesan — gabungan message dan messages
  List<String> get allMessages {
    if (messages.isNotEmpty) return messages;
    if (message.isNotEmpty) return [message];
    return [];
  }

  /// Teks error yang siap ditampilkan ke user
  String get errorText => allMessages.join('\n');
}
