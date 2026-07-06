import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import '../data/assessment_endpoints.dart';

/// Handler untuk mengirim jawaban tes ke server.
///
/// Implementasi QueueHandler dari core_network — didaftarkan
/// ke QueueSyncManager khusus assessment yang pakai RetryPolicy.unlimited().
///
/// Payload [QueueItem.data] berisi:
///   {
///     "session_id": "...",
///     "question_id": "...",
///     "answer_type": "single_choice" | "multiple_choice" | "matrix" | "open_ended",
///     "answer_payload": { ... }  // struktur beda tergantung answer_type
///   }
class AnswerQueueHandler implements QueueHandler {
  const AnswerQueueHandler(this._apiClient);

  final ApiClient _apiClient;

  @override
  String get type => 'assessment_answer';

  @override
  Future<bool> handle(QueueItem item) async {
    final sessionId = item.data['session_id'] as String;
    final questionId = item.data['question_id'] as String;
    final answerType = item.data['answer_type'] as String;
    final answerPayload = item.data['answer_payload'];

    try {
      final response = await _apiClient.post<void>(
        AssessmentEndpoints.submitAnswer(sessionId),
        data: {
          'question_id': questionId,
          'answer_type': answerType,
          'answer': answerPayload,
        },
      );

      return response.isSuccess;
    } on ValidationException catch (e) {
      // Error validasi tidak akan pernah berhasil meski di-retry
      // (misal: question_id tidak valid) — log dan anggap "selesai"
      // agar tidak macet di queue selamanya untuk error yang permanen
      AppLogger.error(
        '[AssessmentQueue] Validation error untuk soal $questionId: ${e.message}',
      );
      return true; // anggap selesai agar tidak retry tanpa akhir
    } on UnauthorizedException catch (e) {
      // ApiClient sudah otomatis mencoba refresh token sekali sebelum
      // exception ini sampai ke sini — jika masih 401, refresh token juga
      // sudah tidak valid (sesi benar-benar habis). Tetap di-retry (bukan
      // discard) karena jawaban tidak boleh hilang, tapi log secara
      // eksplisit supaya kegagalan ini tidak tenggelam sebagai "unexpected error"
      // dan bisa diselidiki (misal: butuh UI yang minta user login ulang).
      AppLogger.error(
        '[AssessmentQueue] Sesi tidak valid untuk soal $questionId: ${e.message}',
      );
      return false;
    } on NetworkException {
      // Masalah koneksi — boleh di-retry
      return false;
    } on ServerException catch (e) {
      AppLogger.warning(
        '[AssessmentQueue] Server error untuk soal $questionId: ${e.message}',
      );
      return false;
    } catch (e) {
      AppLogger.error('[AssessmentQueue] Unexpected error', e);
      return false;
    }
  }
}
