import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Using Equatable to make testing easier (value equality).
sealed class Failure extends Equatable {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.error, super.stackTrace});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.error, super.stackTrace});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.error, super.stackTrace});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.error, super.stackTrace});
}
