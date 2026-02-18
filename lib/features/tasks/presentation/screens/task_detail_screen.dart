import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/common_button.dart';
import '../../../../core/presentation/widgets/common_text_field.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task? task;
  final String projectId;

  const TaskDetailScreen({super.key, this.task, required this.projectId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _commentController;
  late TaskStatus _status;
  late TaskPriority _priority;
  late DateTime _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _commentController = TextEditingController();
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
      );
      ref.read(taskBoardProvider(widget.projectId).notifier).updateTask(updatedTask);
    } else {
      ref.read(taskBoardProvider(widget.projectId).notifier).addTask(
            _titleController.text,
            _descController.text,
            _dueDate,
            _priority,
          );
    }
    Navigator.pop(context);
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty && _isEditing) {
      final newComments = List<String>.from(widget.task!.comments)
        ..add(_commentController.text);
      final updatedTask = widget.task!.copyWith(comments: newComments);
      ref.read(taskBoardProvider(widget.projectId).notifier).updateTask(updatedTask);
      _commentController.clear();
      Navigator.pop(context);
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommonButton(
          onPressed: _saveChanges,
          text: _isEditing ? 'Save Changes' : 'Create Task',
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                controller: _titleController,
                labelText: 'Task Title',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: _descController,
                labelText: 'Description (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Status & Priority Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _status,
                          decoration: const InputDecoration(),
                          items: TaskStatus.values
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.name[0].toUpperCase() + s.name.substring(1),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TaskPriority>(
                          initialValue: _priority,
                          decoration: const InputDecoration(),
                          items: TaskPriority.values
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _priorityColor(p),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          p.name[0].toUpperCase() + p.name.substring(1),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _priority = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Due Date
              Text('Due Date', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        '${_dueDate.day} / ${_dueDate.month} / ${_dueDate.year}',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              // Comments section (edit mode only)
              if (_isEditing) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                Text('Comments',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (widget.task!.comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No comments yet.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ...widget.task!.comments.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Text(c,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textPrimary)),
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
