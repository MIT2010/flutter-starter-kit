import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:shared_assessment/shared_assessment.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/assessment_local_datasource.dart';
import '../datasources/assessment_remote_datasource.dart';
import '../models/assessment_session_model.dart';

/// Implementasi AssessmentRepository.
/// Menangkap AppException dari datasource dan mengubahnya
/// menjadi Failure yang dimengerti domain layer.
class AssessmentRepositoryImpl implements AssessmentRepository {
  const AssessmentRepositoryImpl({
    required AssessmentRemoteDataSource remoteDataSource,
    required AssessmentLocalDataSource localDataSource,
    required this._networkInfo,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final AssessmentRemoteDataSource _remote;
  final AssessmentLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  FutureEither<AssessmentEntity> getAssessment(String assessmentId) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.getAssessment(assessmentId);
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('getAssessment error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<AssessmentSessionEntity> startSession(
    String assessmentId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final model = await _remote.startSession(assessmentId);
      await _local.saveActiveSession(model);
      return Either.right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('startSession error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<AssessmentSessionEntity?> getActiveSession() async {
    try {
      final model = await _local.getActiveSession();
      return Either.right(model?.toEntity());
    } catch (e) {
      AppLogger.error('getActiveSession error', e);
      return Either.left(CacheFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<Unit> saveProgress(AssessmentSessionEntity session) async {
    try {
      await _local.saveActiveSession(
        AssessmentSessionModel.fromEntity(session),
      );
      return Either.right(unit);
    } catch (e) {
      AppLogger.error('saveProgress error', e);
      return Either.left(CacheFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<Unit> completeSession(String sessionId) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      await _remote.completeSession(sessionId);
      await _local.clearActiveSession();
      return Either.right(unit);
    } on UnauthorizedException catch (e) {
      return Either.left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Either.left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      AppLogger.error('completeSession error', e);
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
