import 'package:equatable/equatable.dart';

/// Status item dalam antrian
enum QueueItemStatus {
  pending,    // menunggu dikirim
  syncing,    // sedang dalam proses kirim
  failed,     // gagal setelah max retry (hanya untuk limited queue)
  completed,  // berhasil dikirim (akan dihapus dari queue)
}

/// Item generik dalam offline queue.
/// Setiap fitur bisa extend payload sesuai kebutuhan via [data].
class QueueItem extends Equatable {
  const QueueItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.status = QueueItemStatus.pending,
    this.retryCount = 0,
    this.lastAttemptAt,
    this.lastError,
  });

  /// ID unik item — gunakan UUID
  final String id;

  /// Tipe operasi — dipakai untuk routing ke handler yang tepat
  /// Contoh: 'assessment_answer', 'update_profile'
  final String type;

  /// Payload data dalam bentuk JSON — fleksibel untuk semua jenis operasi
  final Map<String, dynamic> data;

  final DateTime createdAt;
  final QueueItemStatus status;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String? lastError;

  QueueItem copyWith({
    QueueItemStatus? status,
    int? retryCount,
    DateTime? lastAttemptAt,
    String? lastError,
  }) {
    return QueueItem(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'retryCount': retryCount,
        'lastAttemptAt': lastAttemptAt?.toIso8601String(),
        'lastError': lastError,
      };

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: QueueItemStatus.values.byName(json['status'] as String),
      retryCount: json['retryCount'] as int,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      lastError: json['lastError'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        data,
        createdAt,
        status,
        retryCount,
        lastAttemptAt,
        lastError,
      ];
}
