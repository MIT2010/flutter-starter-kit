import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:uuid/uuid.dart';

/// Service untuk submit jawaban tes — per soal, bukan batch.
///
/// Setiap kali user jawab satu soal, langsung dikirim via
/// QueueSyncManager. Online → kirim langsung. Offline → masuk antrian
/// dan akan terus dicoba sampai berhasil (RetryPolicy.unlimited).
class AnswerSubmissionService {
  AnswerSubmissionService(this._queueManager);

  final QueueSyncManager _queueManager;
  final _uuid = const Uuid();

  /// Submit jawaban single/multiple choice
  Future<void> submitChoiceAnswer({
    required String sessionId,
    required String questionId,
    required String answerType, // 'single_choice' | 'multiple_choice'
    required dynamic selectedOptionIds, // String atau List<String>
  }) async {
    await _queueManager.enqueue(
      QueueItem(
        id: _uuid.v4(),
        type: 'assessment_answer',
        data: {
          'session_id': sessionId,
          'question_id': questionId,
          'answer_type': answerType,
          'answer_payload': {'selected_option_ids': selectedOptionIds},
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Submit jawaban matrix
  Future<void> submitMatrixAnswer({
    required String sessionId,
    required String questionId,
    required Map<String, String> selections,
  }) async {
    await _queueManager.enqueue(
      QueueItem(
        id: _uuid.v4(),
        type: 'assessment_answer',
        data: {
          'session_id': sessionId,
          'question_id': questionId,
          'answer_type': 'matrix',
          'answer_payload': {'selections': selections},
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Submit jawaban open-ended
  Future<void> submitOpenEndedAnswer({
    required String sessionId,
    required String questionId,
    required String text,
  }) async {
    await _queueManager.enqueue(
      QueueItem(
        id: _uuid.v4(),
        type: 'assessment_answer',
        data: {
          'session_id': sessionId,
          'question_id': questionId,
          'answer_type': 'open_ended',
          'answer_payload': {'text': text},
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Jumlah jawaban yang masih menunggu sync — untuk indicator di UI
  Future<int> get pendingAnswersCount => _queueManager.pendingCount;
}
