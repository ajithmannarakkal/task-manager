import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_dto.g.dart';

@JsonSerializable()
class TaskDto extends Task {
  const TaskDto({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.priority,
    required super.status,
    super.comments,
  });

  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
      comments: task.comments,
    );
  }

  factory TaskDto.fromJson(Map<String, dynamic> json) => _$TaskDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}
