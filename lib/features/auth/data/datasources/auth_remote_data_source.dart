import 'dart:math';

import '../../../../core/error/failure.dart';
import '../models/auth_user_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthUserDto> login(String email, String password);
  Future<void> logout();
  Future<AuthUserDto?> checkAuthStatus();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final Random _random = Random();
  AuthUserDto? _currentUser;

  @override
  Future<AuthUserDto> login(String email, String password) async {
    // TODO: Replace with real API call
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(1000)));

    if (_random.nextDouble() < 0.05) {
      throw const ServerFailure('Random server error occurred');
    }

    if (password.isEmpty) {
      throw const ValidationFailure('Password cannot be empty');
    }

    _currentUser = AuthUserDto(
      id: 'user_${_random.nextInt(1000)}',
      email: email,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<AuthUserDto?> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}
