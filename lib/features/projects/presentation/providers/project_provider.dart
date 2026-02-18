import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/project_remote_data_source.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/get_projects.dart';

// --- Data Layer Providers ---

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  return MockProjectRemoteDataSource();
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ref.watch(projectRemoteDataSourceProvider));
});

// --- Domain Layer Providers ---

final getProjectsUseCaseProvider = Provider<GetProjects>((ref) {
  return GetProjects(ref.watch(projectRepositoryProvider));
});

final createProjectUseCaseProvider = Provider<CreateProject>((ref) {
  return CreateProject(ref.watch(projectRepositoryProvider));
});

final deleteProjectUseCaseProvider = Provider<DeleteProject>((ref) {
  return DeleteProject(ref.watch(projectRepositoryProvider));
});

// --- Presentation Layer (State) ---

final projectListProvider = AsyncNotifierProvider<ProjectNotifier, List<Project>>(() {
  return ProjectNotifier();
});

class ProjectNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    return _fetchProjects();
  }

  Future<List<Project>> _fetchProjects() async {
    final getProjects = ref.read(getProjectsUseCaseProvider);
    final result = await getProjects(const NoParams());
    return result.fold(
      (failure) => throw failure,
      (projects) => projects,
    );
  }

  Future<void> addProject(String name, String description, Color color) async {
    final createProject = ref.read(createProjectUseCaseProvider);
    final newProject = Project(
      id: '',
      name: name,
      description: description,
      color: color,
    );

    state = const AsyncValue.loading();
    final result = await createProject(newProject);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> deleteProject(String projectId) async {
    final deleteProject = ref.read(deleteProjectUseCaseProvider);
    
    // Optimistic update
    final previousState = state.value;
    if (previousState != null) {
      state = AsyncValue.data(previousState.where((p) => p.id != projectId).toList());
      
      final result = await deleteProject(projectId);
      
      result.fold(
        (failure) {
           state = AsyncValue.data(previousState); // Revert
           state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (_) {},
      );
    }
  }
}
