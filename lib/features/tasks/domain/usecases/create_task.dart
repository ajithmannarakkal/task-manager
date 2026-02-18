import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTask implements UseCase<Task, Task> {
  final TaskRepository _repository;

  CreateTask(this._repository);

  @override
  Future<Result<Task>> call(Task params) async {
    return await _repository.createTask(params);
  }
}
