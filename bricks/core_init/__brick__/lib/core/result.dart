/// A success/failure union with no exceptions crossing into the UI layer.
///
/// Repository methods that can fail return `Result<Failure, S>` — never
/// `null` to mean failure, and never a thrown exception. Cubits pattern-match
/// on this (or use [fold]) and never let a raw exception reach the view.
sealed class Result<F, S> {
  const Result();

  const factory Result.success(S value) = Success<F, S>;

  const factory Result.failure(F failure) = ResultFailure<F, S>;

  bool get isSuccess => this is Success<F, S>;

  bool get isFailure => this is ResultFailure<F, S>;

  R fold<R>({
    required R Function(F failure) onFailure,
    required R Function(S success) onSuccess,
  }) {
    return switch (this) {
      Success<F, S>(:final value) => onSuccess(value),
      ResultFailure<F, S>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<F, S> extends Result<F, S> {
  const Success(this.value);

  final S value;
}

final class ResultFailure<F, S> extends Result<F, S> {
  const ResultFailure(this.failure);

  final F failure;
}
