import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_dto.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Task>>> getTasks(String projectId) async {
    try {
      final dtos = await _dataSource.getTasks(projectId);
      return Success(dtos);
    } on Failure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Task>> createTask(Task task) async {
    try {
      final taskDto = TaskDto.fromDomain(task);
      final createdTaskDto = await _dataSource.createTask(taskDto);
      return Success(createdTaskDto);
    } on Failure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    try {
      final taskDto = TaskDto.fromDomain(task);
      final updatedTaskDto = await _dataSource.updateTask(taskDto);
      return Success(updatedTaskDto);
    } on Failure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTask(String taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
      return const Success(null);
    } on Failure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }
}
