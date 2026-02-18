import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/projects/presentation/screens/project_dashboard_screen.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      title: 'Task Manger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer(
        builder: (context, ref, _) {
          final authState = ref.watch(authNotifierProvider);
          
          return authState.when(
            data: (user) {
              if (user != null) {
                return const ProjectDashboardScreen(key: ValueKey('dashboard'));
              }
              return const LoginScreen(key: ValueKey('login'));
            },
            loading: () {
              if (authState.hasValue) {
                return authState.valueOrNull != null
                    ? const ProjectDashboardScreen(key: ValueKey('dashboard'))
                    : const LoginScreen(key: ValueKey('login'));
              }
              return const SplashScreen(key: ValueKey('splash'));
            },
            error: (err, stack) => const LoginScreen(key: ValueKey('login')),
          );
        },
      ),
    );
  }
}
