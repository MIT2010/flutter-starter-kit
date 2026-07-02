import 'package:core/core.dart';
import '../repositories/assessment_repository.dart';

class CompleteAssessmentSessionUseCase {
  const CompleteAssessmentSessionUseCase(this._repository);

  final AssessmentRepository _repository;

  FutureEither<Unit> call(String sessionId) {
    return _repository.completeSession(sessionId);
  }
}
