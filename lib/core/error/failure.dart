import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Using sealed class for exhaustive pattern matching.
sealed class Failure extends Equatable {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];
}

/// Failure from a remote server (HTTP errors, API errors).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.error, super.stackTrace});
}

/// Failure from local cache or storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.error, super.stackTrace});
}

/// Failure due to invalid user input or data.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.error, super.stackTrace});
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.error, super.stackTrace});
}

/// Failure due to authentication / authorization issues.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.error, super.stackTrace});
}

/// Fallback for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.error, super.stackTrace});
}
