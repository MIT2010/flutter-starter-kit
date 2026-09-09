import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/result.dart';

void main() {
  group('Result', () {
    test('success carries the value and reports isSuccess', () {
      const result = Result<String, int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.fold(onFailure: (f) => -1, onSuccess: (s) => s), 42);
    });

    test('failure carries the failure and reports isFailure', () {
      const result = Result<String, int>.failure('nope');

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(
        result.fold(onFailure: (f) => f, onSuccess: (s) => 'unexpected'),
        'nope',
      );
    });

    test('supports pattern matching on the concrete variants', () {
      const Result<String, int> result = Result.success(7);

      final doubled = switch (result) {
        Success<String, int>(:final value) => value * 2,
        ResultFailure<String, int>() => -1,
      };

      expect(doubled, 14);
    });
  });
}
