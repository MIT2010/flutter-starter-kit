/// Generic, user-safe failure types.
///
/// Repository error handling must always map real errors (backend messages,
/// exceptions, raw response bodies) onto one of these — never surface a raw
/// backend error string directly to UI-facing state. See docs/decisions for
/// the reasoning.
///
/// The one deliberate carve-out is [MessageFailure]: some backends author
/// their error `message`/`msg` field specifically as display copy ("Wrong
/// password", "Item not found"). When that is confirmed true of a real
/// backend (ask whoever owns it), a repository may pass that string through
/// as a [MessageFailure]. Everything exception-shaped, malformed, or
/// unexpected still maps to a generic type above. See
/// docs/decisions/ADR-0005 and the `flutter-starter-kit-conventions` skill.
sealed class Failure {
  const Failure(this.message);

  /// A short, user-safe message. Safe to show directly in the UI.
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'A network error occurred. Please check your connection and try again.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our end. Please try again later.',
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read locally stored data.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

/// A failure carrying a message that is already safe to show as-is.
///
/// ONLY for strings authored by a human to be read by an end user:
///   - a backend `message`/`msg` field that its maintainer confirms is
///     written as user-facing copy, or
///   - a client-side validation string this app itself wrote.
///
/// NEVER pass a raw exception's text, an HTTP status phrase, a stack trace,
/// a malformed-response description, or a `DioException.toString()` into
/// this — those were never written for a user to read. Route them through
/// `mapDioError` / the generic types above instead. Misusing this type
/// makes the whole "no raw backend strings in the UI" rule meaningless, so
/// keep its call sites few and obvious.
final class MessageFailure extends Failure {
  const MessageFailure(super.message);
}
