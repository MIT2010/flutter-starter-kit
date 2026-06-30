import 'dart:async';
import 'package:core/core.dart';
import 'package:core_storage/core_storage.dart';
import '../network_info.dart';
import 'queue_handler.dart';
import 'retry_policy.dart';

/// Orchestrator untuk offline queue.
///
/// Tanggung jawab:
/// - Listen perubahan koneksi secara OTOMATIS
/// - Proses item queue secara PARALEL saat online
/// - Terapkan retry policy (unlimited / limited)
/// - Pindahkan item ke failed status jika limit tercapai
///
/// Satu instance untuk satu jenis queue (assessment / generic).
/// Setiap fitur yang pakai queue ini harus daftarkan [QueueHandler]
/// untuk tipe data yang dimilikinya.
class QueueSyncManager {
  QueueSyncManager({
    required QueueStorage storage,
    required NetworkInfo networkInfo,
    required RetryPolicy retryPolicy,
  })  : _storage = storage,
        _networkInfo = networkInfo,
        _retryPolicy = retryPolicy;

  final QueueStorage _storage;
  final NetworkInfo _networkInfo;
  final RetryPolicy _retryPolicy;

  final Map<String, QueueHandler> _handlers = {};

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  bool _wasOffline = false;

  /// Daftarkan handler untuk tipe data tertentu.
  /// Panggil ini saat bootstrap untuk setiap fitur yang pakai queue.
  void registerHandler(QueueHandler handler) {
    _handlers[handler.type] = handler;
    AppLogger.debug('[Queue] Handler registered: ${handler.type}');
  }

  /// Mulai listen perubahan koneksi — panggil sekali saat bootstrap.
  /// Saat koneksi berubah dari offline → online, otomatis trigger sync.
  void startAutoSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      (isOnline) {
        if (isOnline && _wasOffline) {
          AppLogger.info('[Queue] Connection restored, auto-syncing...');
          syncAll();
        }
        _wasOffline = !isOnline;
      },
    );
    AppLogger.debug('[Queue] Auto-sync listener started');
  }

  void stopAutoSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Tambahkan item baru ke queue.
  /// Langsung coba kirim jika online, masuk antrian jika offline.
  Future<void> enqueue(QueueItem item) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      await _storage.save(item);
      AppLogger.debug('[Queue] Item queued (offline): ${item.id}');
      return;
    }

    final success = await _tryHandle(item);
    if (!success) {
      await _storage.save(item);
      AppLogger.debug('[Queue] Item queued (send failed): ${item.id}');
    }
  }

  /// Proses semua item pending secara PARALEL.
  /// Dipanggil otomatis saat koneksi kembali, atau bisa dipanggil manual.
  Future<void> syncAll() async {
    if (_isSyncing) {
      AppLogger.debug('[Queue] Sync already in progress, skip');
      return;
    }

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      AppLogger.debug('[Queue] Sync skipped — offline');
      return;
    }

    _isSyncing = true;
    AppLogger.info('[Queue] Starting sync...');

    try {
      final pending = await _storage.getByStatus(QueueItemStatus.pending);

      if (pending.isEmpty) {
        AppLogger.debug('[Queue] No pending items');
        return;
      }

      AppLogger.info('[Queue] Syncing ${pending.length} items in parallel');

      await Future.wait(
        pending.map((item) => _processItem(item)),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processItem(QueueItem item) async {
    final updated = item.copyWith(
      status: QueueItemStatus.syncing,
      lastAttemptAt: DateTime.now(),
    );
    await _storage.save(updated);

    final success = await _tryHandle(updated);

    if (success) {
      await _storage.remove(item.id);
      AppLogger.info('[Queue] Item synced successfully: ${item.id}');
      return;
    }

    final newRetryCount = item.retryCount + 1;

    if (_retryPolicy.shouldRetry(newRetryCount)) {
      await _storage.save(
        updated.copyWith(
          status: QueueItemStatus.pending,
          retryCount: newRetryCount,
        ),
      );
      AppLogger.warning(
        '[Queue] Item failed, will retry (attempt $newRetryCount): ${item.id}',
      );
    } else {
      await _storage.save(
        updated.copyWith(
          status: QueueItemStatus.failed,
          retryCount: newRetryCount,
        ),
      );
      AppLogger.error(
        '[Queue] Item failed permanently after $newRetryCount attempts: ${item.id}',
      );
    }
  }

  Future<bool> _tryHandle(QueueItem item) async {
    final handler = _handlers[item.type];
    if (handler == null) {
      AppLogger.error('[Queue] No handler registered for type: ${item.type}');
      return false;
    }

    try {
      return await handler.handle(item);
    } catch (e, st) {
      AppLogger.error('[Queue] Handler error for ${item.id}', e, st);
      return false;
    }
  }

  /// Retry manual item yang sudah failed — dipanggil dari UI
  Future<void> retryFailed(String itemId) async {
    final all = await _storage.getAll();
    final item = all.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return;

    await _storage.save(
      item.copyWith(status: QueueItemStatus.pending, retryCount: 0),
    );
    await syncAll();
  }

  /// Hapus item failed yang tidak ingin di-retry lagi
  Future<void> discardFailed(String itemId) async {
    await _storage.remove(itemId);
  }

  /// Jumlah item pending — untuk indicator di UI
  Future<int> get pendingCount => _storage.pendingCount;

  /// Daftar item yang gagal permanen — untuk ditampilkan di UI
  Future<List<QueueItem>> get failedItems =>
      _storage.getByStatus(QueueItemStatus.failed);

  void dispose() {
    stopAutoSync();
  }
}
