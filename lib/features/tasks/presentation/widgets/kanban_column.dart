import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class KanbanColumn extends ConsumerWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final String projectId;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) => details.data.status != status,
        onAcceptWithDetails: (details) {
           ref.read(taskBoardProvider(projectId).notifier).updateTaskStatus(details.data, status);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: candidateData.isNotEmpty
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Padding(
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == TaskStatus.todo ? Icons.circle_outlined :
                          status == TaskStatus.inProgress ? Icons.timelapse : Icons.check_circle_outline,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            status.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                   ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Draggable<Task>(
                        data: task,
                        feedback: Transform.scale(
                          scale: 1.05,
                          child: SizedBox(
                            width: 200,
                            child: Material(
                              color: Colors.transparent,
                              child: TaskCard(task: task),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
                        child: TaskCard(task: task),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


}
