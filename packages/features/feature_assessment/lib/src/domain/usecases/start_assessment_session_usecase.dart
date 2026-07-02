import 'package:core/core.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../repositories/assessment_repository.dart';

class StartAssessmentSessionUseCase {
  const StartAssessmentSessionUseCase(this._repository);

  final AssessmentRepository _repository;

  FutureEither<AssessmentSessionEntity> call(String assessmentId) {
    return _repository.startSession(assessmentId);
  }
}
