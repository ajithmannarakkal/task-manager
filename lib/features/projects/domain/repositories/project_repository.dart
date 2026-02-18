import '../../../../core/error/result.dart';
import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<Result<List<Project>>> getProjects();
  Future<Result<Project>> createProject(Project project);
  Future<Result<Project>> updateProject(Project project);
  Future<Result<void>> deleteProject(String projectId);
}
