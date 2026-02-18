import 'package:equatable/equatable.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class Login implements UseCase<AuthUser, LoginParams> {
  final AuthRepository _repository;

  Login(this._repository);

  @override
  Future<Result<AuthUser>> call(LoginParams params) async {
    return await _repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
