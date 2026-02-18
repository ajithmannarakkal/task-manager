import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProject implements UseCase<Project, Project> {
  final ProjectRepository _repository;

  CreateProject(this._repository);

  @override
  Future<Result<Project>> call(Project params) async {
    return await _repository.createProject(params);
  }
}
