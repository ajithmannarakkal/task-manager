import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project.dart';

part 'project_dto.g.dart';

@JsonSerializable()
class ProjectDto extends Project {
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  @override
  // ignore: overridden_fields
  final Color color; // Storing as int in JSON, converting here

  const ProjectDto({
    required super.id,
    required super.name,
    required super.description,
    required this.color,
  }) : super(color: color);

  factory ProjectDto.fromDomain(Project project) {
    return ProjectDto(
      id: project.id,
      name: project.name,
      description: project.description,
      color: project.color,
    );
  }

  factory ProjectDto.fromJson(Map<String, dynamic> json) => _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);

  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.toARGB32();
}
