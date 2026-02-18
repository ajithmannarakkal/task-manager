import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus implements UseCase<AuthUser?, NoParams> {
  final AuthRepository _repository;

  CheckAuthStatus(this._repository);

  @override
  Future<Result<AuthUser?>> call(NoParams params) async {
    return await _repository.checkAuthStatus();
  }
}
