import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../../../core/services/notification_service.dart';

// --- Data Layer Providers ---

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return MockTaskRemoteDataSource();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

// --- Domain Layer Providers ---

final getTasksUseCaseProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTask>((ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

// --- Presentation Layer (State) ---

final taskBoardProvider =
    AsyncNotifierProvider.family<TaskBoardNotifier, List<Task>, String>(() {
  return TaskBoardNotifier();
});

class TaskBoardNotifier extends FamilyAsyncNotifier<List<Task>, String> {
  late String _projectId;

  @override
  Future<List<Task>> build(String arg) async {
    _projectId = arg;
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final getTasks = ref.read(getTasksUseCaseProvider);
    final result = await getTasks(_projectId);
    return result.fold(
      (failure) => throw failure,
      (tasks) => tasks,
    );
  }

  Future<void> addTask(
    String title,
    String description,
    DateTime dueDate,
    TaskPriority priority,
  ) async {
    final createTask = ref.read(createTaskUseCaseProvider);
    final notifications = ref.read(notificationServiceProvider);

    final newTask = Task(
      id: '',
      projectId: _projectId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
    );

    state = const AsyncValue.loading();
    final result = await createTask(newTask);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (createdTask) {
        ref.invalidateSelf();

        // Notify task created
        notifications.notifyTaskCreated(title);

        // Schedule due-date reminders
        final taskId = createdTask.id.hashCode;
        notifications.scheduleDueDateReminder(
          id: taskId,
          taskTitle: title,
          dueDate: dueDate,
        );
        notifications.scheduleSameDayReminder(
          id: taskId,
          taskTitle: title,
          dueDate: dueDate,
        );
      },
    );
  }

  Future<void> updateTask(Task task) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      previousState.map((t) => t.id == task.id ? task : t).toList(),
    );

    final updateTaskUseCase = ref.read(updateTaskUseCaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    final result = await updateTaskUseCase(task);

    result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(previousState);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        // Notify task updated
        notifications.notifyTaskUpdated(task.title, id: task.id.hashCode);

        // Re-schedule due-date reminders with updated due date
        final taskId = task.id.hashCode;
        notifications.scheduleDueDateReminder(
          id: taskId,
          taskTitle: task.title,
          dueDate: task.dueDate,
        );
        notifications.scheduleSameDayReminder(
          id: taskId,
          taskTitle: task.title,
          dueDate: task.dueDate,
        );
      },
    );
  }

  Future<void> updateTaskStatus(Task task, TaskStatus newStatus) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    final updatedTask = task.copyWith(status: newStatus);
    state = AsyncValue.data(
      previousState.map((t) => t.id == task.id ? updatedTask : t).toList(),
    );

    final updateTask = ref.read(updateTaskUseCaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    final result = await updateTask(updatedTask);

    result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(previousState);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        // Fire completion notification when moved to Done
        if (newStatus == TaskStatus.done && task.status != TaskStatus.done) {
          notifications.notifyTaskCompleted(
            task.title,
            id: task.id.hashCode,
          );
          // Cancel due-date reminders since task is done
          notifications.cancelNotification(task.id.hashCode);
        }
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      previousState.where((t) => t.id != taskId).toList(),
    );

    final deleteTaskUseCase = ref.read(deleteTaskUseCaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    final result = await deleteTaskUseCase(taskId);

    result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(previousState);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        // Cancel any pending reminders for this task
        notifications.cancelNotification(taskId.hashCode);
      },
    );
  }
}
