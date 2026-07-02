import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnlimitedRetryPolicy', () {
    const policy = RetryPolicy.unlimited();

    test('shouldRetry selalu true berapa pun jumlah percobaannya', () {
      expect(policy.shouldRetry(0), true);
      expect(policy.shouldRetry(1), true);
      expect(policy.shouldRetry(100), true);
      expect(policy.shouldRetry(100000), true);
    });
  });

  group('LimitedRetryPolicy', () {
    const policy = RetryPolicy.limited(maxAttempts: 5);

    test('shouldRetry true selama masih di bawah maxAttempts', () {
      expect(policy.shouldRetry(0), true);
      expect(policy.shouldRetry(4), true);
    });

    test('shouldRetry false setelah mencapai maxAttempts', () {
      expect(policy.shouldRetry(5), false);
      expect(policy.shouldRetry(6), false);
    });
  });

  group('delayForAttempt (exponential backoff)', () {
    const policy = RetryPolicy.limited(maxAttempts: 10);

    test('mengikuti kurva 2^attempt detik', () {
      expect(policy.delayForAttempt(0), const Duration(seconds: 1));
      expect(policy.delayForAttempt(1), const Duration(seconds: 2));
      expect(policy.delayForAttempt(2), const Duration(seconds: 4));
      expect(policy.delayForAttempt(3), const Duration(seconds: 8));
      expect(policy.delayForAttempt(4), const Duration(seconds: 16));
      expect(policy.delayForAttempt(5), const Duration(seconds: 32));
    });

    test('di-clamp ke maksimal 60 detik untuk attempt besar', () {
      expect(policy.delayForAttempt(6), const Duration(seconds: 60));
      expect(policy.delayForAttempt(10), const Duration(seconds: 60));
      expect(policy.delayForAttempt(30), const Duration(seconds: 60));
    });
  });
}
