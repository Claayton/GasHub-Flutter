import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/auth_service.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/auth/auth_state.dart';
import 'config/firebase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();

  runApp(
    BlocProvider(
      create: (_) => AuthCubit(AuthService()),
      child: const GasHubApp(),
    ),
  );
}

class GasHubApp extends StatelessWidget {
  const GasHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasHub - Gestão de Pedidos',
      theme: ThemeData(
        primaryColor: const Color(0xFF1e40af),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1e40af),
          primary: const Color(0xFF1e40af),
          secondary: const Color(0xFF3b82f6),
          surface: const Color(0xFFf8fafc),
        ),
        scaffoldBackgroundColor: const Color(0xFFf8fafc),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1e40af),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: true,
      home: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showDialog(context, 'Erro', state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const SplashScreen();
          } else if (state is AuthAuthenticated) {
            return MainNavigationScreen();
          } else if (state is AuthError) {
            return const LoginScreen();
          } else {
            return const LoginScreen(); // AuthUnauthenticated
          }
        },
      ),
    );
  }

  static void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
