import 'dart:convert';
import 'package:core_storage/core_storage.dart';
import '../models/assessment_session_model.dart';

abstract class _AssessmentStorageKeys {
  static const activeSession = 'assessment_active_session';
}

abstract class AssessmentLocalDataSource {
  Future<void> saveActiveSession(AssessmentSessionModel session);
  Future<AssessmentSessionModel?> getActiveSession();
  Future<void> clearActiveSession();
}

/// Cache progress sesi tes yang sedang berjalan supaya tidak hilang kalau
/// app di-kill di tengah pengerjaan. Starter kit ini hanya mendukung satu
/// sesi aktif dalam satu waktu, jadi key-nya tetap (bukan per-assessmentId).
class AssessmentLocalDataSourceImpl implements AssessmentLocalDataSource {
  AssessmentLocalDataSourceImpl(this._storage);

  final HiveStorage<String> _storage;

  @override
  Future<void> saveActiveSession(AssessmentSessionModel session) {
    return _storage.put(
      _AssessmentStorageKeys.activeSession,
      jsonEncode(session.toJson()),
    );
  }

  @override
  Future<AssessmentSessionModel?> getActiveSession() async {
    final raw = await _storage.get(_AssessmentStorageKeys.activeSession);
    if (raw == null) return null;
    return AssessmentSessionModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> clearActiveSession() {
    return _storage.delete(_AssessmentStorageKeys.activeSession);
  }
}
