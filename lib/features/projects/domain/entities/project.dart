import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final Color color;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, name, description, color];
}
