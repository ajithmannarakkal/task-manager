import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failure.dart';
import '../models/auth_user_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthUserDto> login(String email, String password);
  Future<void> logout();
  Future<AuthUserDto?> checkAuthStatus();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final Random _random = Random();
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _userIdKey = 'auth_user_id';

  MockAuthRemoteDataSource({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<AuthUserDto> login(String email, String password) async {
    // TODO: Replace with real API call
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

    if (password.isEmpty) {
      throw const ValidationFailure('Password cannot be empty');
    }

    final userId = 'user_${_random.nextInt(1000)}';
    final token = 'token_${_random.nextInt(999999)}';

    // Persist auth token and user info in secure storage
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _userIdKey, value: userId);

    return AuthUserDto(id: userId, email: email);
  }

  @override
  Future<void> logout() async {
    // Clear all stored auth keys on logout
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  @override
  Future<AuthUserDto?> checkAuthStatus() async {
    // Check if a valid token exists in secure storage
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return null;

    final email = await _secureStorage.read(key: _emailKey);
    final userId = await _secureStorage.read(key: _userIdKey);

    if (email == null || userId == null) return null;

    return AuthUserDto(id: userId, email: email);
  }
}
