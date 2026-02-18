import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjects implements UseCase<List<Project>, NoParams> {
  final ProjectRepository _repository;

  GetProjects(this._repository);

  @override
  Future<Result<List<Project>>> call(NoParams params) async {
    return await _repository.getProjects();
  }
}
