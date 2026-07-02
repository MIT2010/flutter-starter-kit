import 'dart:async';

import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'queue_sync_manager_test.mocks.dart';

@GenerateMocks([QueueStorage, NetworkInfo, QueueHandler])
void main() {
  setUpAll(() {
    AppLogger.init();
  });

  late MockQueueStorage mockStorage;
  late MockNetworkInfo mockNetworkInfo;
  late MockQueueHandler mockHandler;
  late QueueSyncManager manager;
  late StreamController<bool> connectivityController;

  QueueItem buildItem({
    String id = 'item-1',
    int retryCount = 0,
    DateTime? lastAttemptAt,
    QueueItemStatus status = QueueItemStatus.pending,
  }) {
    return QueueItem(
      id: id,
      type: 'assessment_answer',
      data: const {'question_id': 'q1'},
      createdAt: DateTime.now(),
      status: status,
      retryCount: retryCount,
      lastAttemptAt: lastAttemptAt,
    );
  }

  setUp(() {
    mockStorage = MockQueueStorage();
    mockNetworkInfo = MockNetworkInfo();
    mockHandler = MockQueueHandler();
    connectivityController = StreamController<bool>.broadcast();

    when(mockHandler.type).thenReturn('assessment_answer');
    when(
      mockNetworkInfo.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(mockStorage.save(any)).thenAnswer((_) async {});
    when(mockStorage.remove(any)).thenAnswer((_) async {});
  });

  tearDown(() async {
    await connectivityController.close();
  });

  group('syncAll', () {
    test('tidak melakukan apa pun saat offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );

      await manager.syncAll();

      verifyNever(mockStorage.getByStatus(any));
    });

    test('item baru (belum pernah dicoba) langsung diproses', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      final item = buildItem();
      when(
        mockStorage.getByStatus(QueueItemStatus.pending),
      ).thenAnswer((_) async => [item]);
      when(mockHandler.handle(any)).thenAnswer((_) async => true);

      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );
      manager.registerHandler(mockHandler);

      await manager.syncAll();

      verify(mockHandler.handle(any)).called(1);
      verify(mockStorage.remove(item.id)).called(1);
    });

    test('item yang masih dalam jendela backoff TIDAK diproses ulang', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // retryCount 1 -> delay 2 detik, baru gagal 500ms lalu -> masih dalam jendela backoff.
      final item = buildItem(
        retryCount: 1,
        lastAttemptAt: DateTime.now().subtract(
          const Duration(milliseconds: 500),
        ),
      );
      when(
        mockStorage.getByStatus(QueueItemStatus.pending),
      ).thenAnswer((_) async => [item]);

      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );
      manager.registerHandler(mockHandler);

      await manager.syncAll();

      verifyNever(mockHandler.handle(any));
    });

    test('item yang sudah lewat jendela backoff diproses lagi', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // retryCount 1 -> delay 2 detik, gagal terakhir 10 detik lalu -> sudah lewat.
      final item = buildItem(
        retryCount: 1,
        lastAttemptAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      when(
        mockStorage.getByStatus(QueueItemStatus.pending),
      ).thenAnswer((_) async => [item]);
      when(mockHandler.handle(any)).thenAnswer((_) async => true);

      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );
      manager.registerHandler(mockHandler);

      await manager.syncAll();

      verify(mockHandler.handle(any)).called(1);
    });

    test(
      'item gagal & retry policy mengizinkan retry -> tetap pending dengan retryCount bertambah',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        final item = buildItem();
        when(
          mockStorage.getByStatus(QueueItemStatus.pending),
        ).thenAnswer((_) async => [item]);
        when(mockHandler.handle(any)).thenAnswer((_) async => false);

        manager = QueueSyncManager(
          storage: mockStorage,
          networkInfo: mockNetworkInfo,
          retryPolicy: const RetryPolicy.unlimited(),
        );
        manager.registerHandler(mockHandler);

        await manager.syncAll();

        final saved = verify(mockStorage.save(captureAny)).captured;
        final lastSaved = saved.last as QueueItem;
        expect(lastSaved.status, QueueItemStatus.pending);
        expect(lastSaved.retryCount, 1);
        verifyNever(mockStorage.remove(any));
      },
    );

    test(
      'item gagal & retry policy melarang retry -> dipindah ke status failed',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        final item = buildItem(retryCount: 4);
        when(
          mockStorage.getByStatus(QueueItemStatus.pending),
        ).thenAnswer((_) async => [item]);
        when(mockHandler.handle(any)).thenAnswer((_) async => false);

        manager = QueueSyncManager(
          storage: mockStorage,
          networkInfo: mockNetworkInfo,
          retryPolicy: const RetryPolicy.limited(maxAttempts: 5),
        );
        manager.registerHandler(mockHandler);

        await manager.syncAll();

        final saved = verify(mockStorage.save(captureAny)).captured;
        final lastSaved = saved.last as QueueItem;
        expect(lastSaved.status, QueueItemStatus.failed);
        expect(lastSaved.retryCount, 5);
      },
    );

    test('item dengan tipe tanpa handler terdaftar dianggap gagal', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      final item = buildItem();
      when(
        mockStorage.getByStatus(QueueItemStatus.pending),
      ).thenAnswer((_) async => [item]);

      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );
      // Sengaja tidak registerHandler().

      await manager.syncAll();

      final saved = verify(mockStorage.save(captureAny)).captured;
      final lastSaved = saved.last as QueueItem;
      expect(lastSaved.status, QueueItemStatus.pending);
    });
  });

  group('startAutoSync', () {
    test(
      'trigger syncAll saat koneksi berubah dari offline ke online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockStorage.getByStatus(QueueItemStatus.pending),
        ).thenAnswer((_) async => <QueueItem>[]);

        manager = QueueSyncManager(
          storage: mockStorage,
          networkInfo: mockNetworkInfo,
          retryPolicy: const RetryPolicy.unlimited(),
        );
        manager.startAutoSync();

        connectivityController.add(false); // offline dulu
        await Future<void>.delayed(Duration.zero);
        connectivityController.add(true); // lalu online -> harus trigger sync
        await Future<void>.delayed(Duration.zero);

        verify(mockStorage.getByStatus(QueueItemStatus.pending)).called(1);
      },
    );

    test('tidak trigger sync jika status online tidak berubah', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockStorage.getByStatus(QueueItemStatus.pending),
      ).thenAnswer((_) async => <QueueItem>[]);

      manager = QueueSyncManager(
        storage: mockStorage,
        networkInfo: mockNetworkInfo,
        retryPolicy: const RetryPolicy.unlimited(),
      );
      manager.startAutoSync();

      connectivityController.add(true);
      await Future<void>.delayed(Duration.zero);

      verifyNever(mockStorage.getByStatus(any));
    });
  });
}
