import 'package:core/core.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../repositories/assessment_repository.dart';

/// Cek apakah ada sesi tes yang belum selesai tersimpan di cache lokal —
/// dipakai untuk resume saat AssessmentIntroPage dibuka.
class GetActiveSessionUseCase {
  const GetActiveSessionUseCase(this._repository);

  final AssessmentRepository _repository;

  FutureEither<AssessmentSessionEntity?> call() {
    return _repository.getActiveSession();
  }
}
