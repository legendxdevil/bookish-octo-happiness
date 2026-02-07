/// Custom exceptions and failure classes for error handling
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server/Network related failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// AI/ML service failures
class AIServiceFailure extends Failure {
  const AIServiceFailure(String message) : super(message);
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Unexpected/Unknown failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}
