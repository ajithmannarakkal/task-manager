import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<List<Task>, String> {
  final TaskRepository _repository;

  GetTasks(this._repository);

  @override
  Future<Result<List<Task>>> call(String projectId) async {
    return await _repository.getTasks(projectId);
  }
}
