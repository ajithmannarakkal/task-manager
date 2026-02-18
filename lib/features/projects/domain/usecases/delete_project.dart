import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class DeleteProject implements UseCase<void, String> {
  final ProjectRepository _repository;

  DeleteProject(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    return await _repository.deleteProject(params);
  }
}
