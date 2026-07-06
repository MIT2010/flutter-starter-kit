/// Konfigurasi endpoint assessment.
/// Ubah nilai ini sesuai dengan backend project kamu.
/// Tidak perlu menyentuh logic apapun — hanya file ini.
abstract class AssessmentEndpoints {
  AssessmentEndpoints._();

  static String detail(String assessmentId) => '/assessment/$assessmentId';

  static String startSession(String assessmentId) =>
      '/assessment/$assessmentId/sessions';

  static String completeSession(String sessionId) =>
      '/assessment/sessions/$sessionId/complete';

  /// Dipakai langsung oleh AnswerQueueHandler (queue/answer_queue_handler.dart)
  /// — sebelumnya sempat di-hardcode ulang di sana sebagai string literal
  /// terpisah, sekarang sudah direfaktor supaya cuma ada satu sumber
  /// kebenaran untuk path ini.
  static String submitAnswer(String sessionId) =>
      '/assessment/sessions/$sessionId/answers';
}
