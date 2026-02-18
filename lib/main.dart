import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/projects/presentation/screens/project_dashboard_screen.dart';
import 'core/services/notification_service.dart';
// import 'features/tasks/presentation/screens/task_board_screen.dart'; // Removed as unused

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // We need a container to read the provider before runApp for initialization,
  // or just initialize inside a provider that is watched.
  // Creating a container here just for initialization.
  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions(); // Request on launch for simplicity

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
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7), // Deep Purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Assuming standard font or default, but styling will be applied by theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 4.0,
          backgroundColor: Color(0xFFF5F5F7), // Light clean background for app bar
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Light grey background like iOS
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
           elevation: 4,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const ProjectDashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => const LoginScreen(),
      ),
    );
  }
}
