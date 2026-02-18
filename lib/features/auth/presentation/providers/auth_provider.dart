import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../../../core/usecases/usecase.dart';

// --- Data Layer Providers ---

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return MockAuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// --- Domain Layer Providers ---

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatus>((ref) {
  return CheckAuthStatus(ref.watch(authRepositoryProvider));
});

// --- Presentation Layer (State) ---

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    // Artificial delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    final checkAuthStatus = ref.read(checkAuthStatusUseCaseProvider);
    final result = await checkAuthStatus(const NoParams());
    
    return result.fold(
      (failure) => null, // Treat failure as not logged in for simplicity
      (user) => user,
    );
  }

  Future<void> login(String email, String password) async {
    // Keep previous state (which is null) while loading to prevent 
    // main.dart from jumping back to the SplashScreen via its .loading branch
    state = const AsyncValue<AuthUser?>.loading().copyWithPrevious(state);
    
    final login = ref.read(loginUseCaseProvider);
    final result = await login(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncValue.data(user);
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final logout = ref.read(logoutUseCaseProvider);
    await logout(const NoParams());
    state = const AsyncValue.data(null);
  }
}
