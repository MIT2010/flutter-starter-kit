import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:feature_assessment/feature_assessment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'answer_queue_handler_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  setUpAll(() {
    AppLogger.init();
  });

  late MockApiClient mockApiClient;
  late AnswerQueueHandler handler;

  final item = QueueItem(
    id: 'item-1',
    type: 'assessment_answer',
    data: const {
      'session_id': 'session-1',
      'question_id': 'question-1',
      'answer_type': 'single_choice',
      'answer_payload': {'selected_option_ids': 'opt-a'},
    },
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockApiClient = MockApiClient();
    handler = AnswerQueueHandler(mockApiClient);
  });

  test('type mengembalikan "assessment_answer"', () {
    expect(handler.type, 'assessment_answer');
  });

  test('mengirim payload yang benar ke endpoint session', () async {
    when(
      mockApiClient.post<void>(any, data: anyNamed('data')),
    ).thenAnswer((_) async => const ApiResponse(isSuccess: true, message: ''));

    await handler.handle(item);

    verify(
      mockApiClient.post<void>(
        '/assessment/sessions/session-1/answers',
        data: {
          'question_id': 'question-1',
          'answer_type': 'single_choice',
          'answer': {'selected_option_ids': 'opt-a'},
        },
      ),
    );
  });

  test('mengembalikan true saat response sukses', () async {
    when(
      mockApiClient.post<void>(any, data: anyNamed('data')),
    ).thenAnswer((_) async => const ApiResponse(isSuccess: true, message: ''));

    final result = await handler.handle(item);

    expect(result, true);
  });

  test('mengembalikan false saat response gagal tanpa exception', () async {
    when(mockApiClient.post<void>(any, data: anyNamed('data'))).thenAnswer(
      (_) async => const ApiResponse(isSuccess: false, message: 'gagal'),
    );

    final result = await handler.handle(item);

    expect(result, false);
  });

  test(
    'mengembalikan true saat ValidationException (dianggap selesai, tidak retry)',
    () async {
      when(
        mockApiClient.post<void>(any, data: anyNamed('data')),
      ).thenThrow(const ValidationException(message: 'question_id invalid'));

      final result = await handler.handle(item);

      expect(result, true);
    },
  );

  test(
    'mengembalikan false saat UnauthorizedException (tetap di-retry, bukan discard)',
    () async {
      when(
        mockApiClient.post<void>(any, data: anyNamed('data')),
      ).thenThrow(const UnauthorizedException());

      final result = await handler.handle(item);

      expect(result, false);
    },
  );

  test('mengembalikan false saat NetworkException (boleh di-retry)', () async {
    when(
      mockApiClient.post<void>(any, data: anyNamed('data')),
    ).thenThrow(const NetworkException());

    final result = await handler.handle(item);

    expect(result, false);
  });

  test('mengembalikan false saat ServerException (boleh di-retry)', () async {
    when(
      mockApiClient.post<void>(any, data: anyNamed('data')),
    ).thenThrow(const ServerException(message: 'Internal Server Error'));

    final result = await handler.handle(item);

    expect(result, false);
  });

  test('mengembalikan false saat error tak terduga', () async {
    when(
      mockApiClient.post<void>(any, data: anyNamed('data')),
    ).thenThrow(Exception('unexpected'));

    final result = await handler.handle(item);

    expect(result, false);
  });
}
