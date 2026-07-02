import 'package:core/core.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../repositories/assessment_repository.dart';

class GetAssessmentUseCase {
  const GetAssessmentUseCase(this._repository);

  final AssessmentRepository _repository;

  FutureEither<AssessmentEntity> call(String assessmentId) {
    if (assessmentId.isEmpty) {
      return Future.value(
        Either.left(
          const ValidationFailure(message: 'ID assessment wajib diisi'),
        ),
      );
    }
    return _repository.getAssessment(assessmentId);
  }
}
