import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<AuthUser>> login(String email, String password) async {
    try {
      final userDto = await _dataSource.login(email, password);
      return Success(userDto);
    } on Failure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.logout();
      return const Success(null);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser?>> checkAuthStatus() async {
    try {
      final userDto = await _dataSource.checkAuthStatus();
      return Success(userDto);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }
}
