import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTask implements UseCase<void, String> {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    return await _repository.deleteTask(params);
  }
}
