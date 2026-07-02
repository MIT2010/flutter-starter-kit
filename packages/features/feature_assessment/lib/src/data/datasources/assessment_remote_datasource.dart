import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import '../assessment_endpoints.dart';
import '../models/assessment_model.dart';
import '../models/assessment_session_model.dart';

abstract class AssessmentRemoteDataSource {
  Future<AssessmentModel> getAssessment(String assessmentId);

  Future<AssessmentSessionModel> startSession(String assessmentId);

  Future<void> completeSession(String sessionId);
}

class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  const AssessmentRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AssessmentModel> getAssessment(String assessmentId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      AssessmentEndpoints.detail(assessmentId),
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return AssessmentModel.fromJson(response.data!);
  }

  @override
  Future<AssessmentSessionModel> startSession(String assessmentId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AssessmentEndpoints.startSession(assessmentId),
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return AssessmentSessionModel.fromJson(response.data!);
  }

  @override
  Future<void> completeSession(String sessionId) async {
    await _apiClient.post<void>(AssessmentEndpoints.completeSession(sessionId));
  }
}
