import 'package:core/core.dart';
import 'package:shared_assessment/shared_assessment.dart';

abstract class AssessmentRepository {
  FutureEither<AssessmentEntity> getAssessment(String assessmentId);

  FutureEither<AssessmentSessionEntity> startSession(String assessmentId);

  /// Ambil sesi yang belum selesai dari cache lokal — untuk resume.
  /// Selalu baca lokal (tidak butuh koneksi); null kalau tidak ada.
  FutureEither<AssessmentSessionEntity?> getActiveSession();

  /// Simpan progress ke cache lokal — dipanggil tiap kali user jawab atau
  /// pindah soal. Selalu berhasil selama tidak ada I/O error lokal.
  FutureEither<Unit> saveProgress(AssessmentSessionEntity session);

  FutureEither<Unit> completeSession(String sessionId);
}
