import 'package:core/core.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../repositories/assessment_repository.dart';

/// Simpan posisi & jawaban sesi ke cache lokal — dipanggil tiap kali user
/// menjawab atau berpindah soal, supaya progress tidak hilang jika app
/// di-kill di tengah pengerjaan.
class SaveSessionProgressUseCase {
  const SaveSessionProgressUseCase(this._repository);

  final AssessmentRepository _repository;

  FutureEither<Unit> call(AssessmentSessionEntity session) {
    return _repository.saveProgress(session);
  }
}
