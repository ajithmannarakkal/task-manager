import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthUser>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<AuthUser?>> checkAuthStatus();
}
