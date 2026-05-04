import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'services/database_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local database (seeds default accounts on first run)
  await DatabaseService.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appProvider = AppProvider();
  // Restore previous session if the user was already logged in
  await appProvider.tryAutoLogin();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: appProvider,
      child: const EduHubApp(),
    ),
  );
}

class EduHubApp extends StatelessWidget {
  const EduHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.dashboard: (_) => const MainShell(),
      },
    );
  }
}

