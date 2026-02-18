import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class Logout implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  Logout(this._repository);

  @override
  Future<Result<void>> call(NoParams params) async {
    return await _repository.logout();
  }
}
