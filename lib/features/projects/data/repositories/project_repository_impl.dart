import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';
import '../models/project_dto.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _dataSource;

  ProjectRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Project>>> getProjects() async {
    try {
      final dtos = await _dataSource.getProjects();
      return Success(dtos);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Project>> createProject(Project project) async {
    try {
      final dto = ProjectDto.fromDomain(project);
      final createdDto = await _dataSource.createProject(dto);
      return Success(createdDto);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    try {
      await _dataSource.deleteProject(projectId);
      return const Success(null);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<Project>> updateProject(Project project) async {
    // Mock implementation for now
     return Success(project);
  }
}
