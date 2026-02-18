import 'dart:math';

import '../models/project_dto.dart';
import 'package:flutter/material.dart';

abstract interface class ProjectRemoteDataSource {
  Future<List<ProjectDto>> getProjects();
  Future<ProjectDto> createProject(ProjectDto project);
  Future<void> deleteProject(String projectId);
}

class MockProjectRemoteDataSource implements ProjectRemoteDataSource {
  final Random _random = Random();
  final List<ProjectDto> _projects = [];

  MockProjectRemoteDataSource() {
    _projects.addAll([
      const ProjectDto(
        id: '1',
        name: 'Personal',
        description: 'Personal tasks and chores',
        color: Colors.blue,
      ),
      const ProjectDto(
        id: '2',
        name: 'Work',
        description: 'Office projects and meetings',
        color: Colors.red,
      ),
    ]);
  }

  Future<void> _simulateNetwork() async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
  }

  @override
  Future<List<ProjectDto>> getProjects() async {
    await _simulateNetwork();
    return List.from(_projects);
  }

  @override
  Future<ProjectDto> createProject(ProjectDto project) async {
    await _simulateNetwork();
    final newProject = ProjectDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: project.name,
      description: project.description,
      color: project.color,
    );
    _projects.add(newProject);
    return newProject;
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _simulateNetwork();
    _projects.removeWhere((p) => p.id == projectId);
  }
}
