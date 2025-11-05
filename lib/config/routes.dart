import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../navigation/main_navigator.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        home: (context) => const MainNavigator(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
      };
}
