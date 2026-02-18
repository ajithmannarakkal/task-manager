import '../../../../core/error/result.dart';
import '../entities/task.dart';

abstract interface class TaskRepository {
  Future<Result<List<Task>>> getTasks(String projectId);
  Future<Result<Task>> createTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String taskId);
}
