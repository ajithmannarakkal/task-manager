import '../error/result.dart';

/// Base interface for all use cases.
/// [Type] is the return type of the use case (wrapped in Result).
/// [Params] is the parameter type passed to the use case.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Helper class for use cases that don't need parameters.
class NoParams {
  const NoParams();
}
