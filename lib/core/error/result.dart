import 'failure.dart';

/// A sealed class representing the result of an operation.
/// It can be either [Success] or [FailureResult].
/// This forces the UI to handle both cases using switch expressions.
sealed class Result<T> {
  const Result();

  /// Execute [onSuccess] if this is a [Success], or [onFailure] if this is a [FailureResult].
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess);
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return onSuccess(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);

  @override
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return onFailure(failure);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
