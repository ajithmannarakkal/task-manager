import 'dart:math';

import '../../../../core/error/failure.dart';
import '../../domain/entities/task.dart';
import '../models/task_dto.dart';

abstract interface class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasks(String projectId);
  Future<TaskDto> createTask(TaskDto task);
  Future<TaskDto> updateTask(TaskDto task);
  Future<void> deleteTask(String taskId);
}

class MockTaskRemoteDataSource implements TaskRemoteDataSource {
  final Random _random = Random();
  final List<TaskDto> _tasks = []; // In-memory storage

  MockTaskRemoteDataSource() {
    // Seed with some initial data
    _tasks.addAll([
      TaskDto(
        id: '1',
        projectId: '1', // Default mock project ID
        title: 'Complete Project Proposal',
        description: 'Draft the initial proposal for the client meeting.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.high,
        status: TaskStatus.todo,
      ),
      TaskDto(
        id: '2',
        projectId: '1',
        title: 'Review Design Assets',
        description: 'Check if all assets are exported correctly.',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
      ),
      TaskDto(
        id: '3',
        projectId: '1',
        title: 'Update Dependecies',
        description: 'Run flutter pub upgrade.',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        priority: TaskPriority.high,
        status: TaskStatus.done,
        comments: ['Fixed in PR #42', 'Deployed to staging'],
      ),
    ]);
  }

  Future<void> _simulateNetwork() async {
    // TODO: Remove this delay when backend is ready
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(1200)));
    
    if (_random.nextDouble() < 0.05) {
       // throw Exception('Random network error');
    }
  }

  @override
  Future<List<TaskDto>> getTasks(String projectId) async {
    await _simulateNetwork();
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<TaskDto> createTask(TaskDto task) async {
    await _simulateNetwork();
    final newTask = TaskDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
      projectId: task.projectId, // Assign projectId from input
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
      comments: task.comments,
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<TaskDto> updateTask(TaskDto task) async {
    await _simulateNetwork();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      return task;
    } else {
      throw const ServerFailure('Task not found');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _simulateNetwork();
    _tasks.removeWhere((t) => t.id == taskId);
  }
}
