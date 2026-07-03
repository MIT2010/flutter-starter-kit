/// Strategi retry untuk offline queue.
sealed class RetryPolicy {
  const RetryPolicy();

  /// Retry tanpa batas — dipakai untuk data kritis yang tidak boleh hilang
  /// Contoh: jawaban assessment
  const factory RetryPolicy.unlimited() = UnlimitedRetryPolicy;

  /// Retry dengan batas maksimal — dipakai untuk operasi non-kritis
  /// Contoh: update profile, like, dll
  const factory RetryPolicy.limited({required int maxAttempts}) =
      LimitedRetryPolicy;

  /// Cek apakah masih boleh retry berdasarkan jumlah percobaan saat ini
  bool shouldRetry(int currentAttempts);

  /// Hitung delay sebelum retry berikutnya (exponential backoff)
  Duration delayForAttempt(int attempt) {
    // 2^attempt detik, max 60 detik
    final seconds = (1 << attempt).clamp(1, 60);
    return Duration(seconds: seconds);
  }
}

class UnlimitedRetryPolicy extends RetryPolicy {
  const UnlimitedRetryPolicy();

  @override
  bool shouldRetry(int currentAttempts) => true;
}

class LimitedRetryPolicy extends RetryPolicy {
  const LimitedRetryPolicy({required this.maxAttempts});

  final int maxAttempts;

  @override
  bool shouldRetry(int currentAttempts) => currentAttempts < maxAttempts;
}
