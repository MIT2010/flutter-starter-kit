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

  /// Dipakai oleh AnswerQueueHandler — jangan diubah tanpa menyesuaikan
  /// packages/features/feature_assessment/lib/src/queue/answer_queue_handler.dart
  static String submitAnswer(String sessionId) =>
      '/assessment/sessions/$sessionId/answers';
}
