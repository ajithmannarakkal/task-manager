import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import '../widgets/kanban_column.dart';

import '../../../../features/projects/domain/entities/project.dart';

class TaskBoardScreen extends ConsumerWidget {
  final Project project;

  const TaskBoardScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskBoardProvider(project.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: tasksAsync.when(
        data: (tasks) => _buildBoard(context, tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (_) => TaskDetailScreen(projectId: project.id),
            ),
          );
        },
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, List<Task> tasks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanbanColumn(
            status: TaskStatus.todo,
            tasks: tasks.where((t) => t.status == TaskStatus.todo).toList(),
            projectId: project.id,
          ),
          const SizedBox(width: 8),
          KanbanColumn(
            status: TaskStatus.inProgress,
            tasks: tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
            projectId: project.id,
          ),
          const SizedBox(width: 8),
          KanbanColumn(
            status: TaskStatus.done,
            tasks: tasks.where((t) => t.status == TaskStatus.done).toList(),
            projectId: project.id,
          ),
        ],
      ),
    );
  }
}
