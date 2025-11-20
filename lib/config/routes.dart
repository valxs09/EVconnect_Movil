import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../navigation/main_navigator.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/payments/payment_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String payment = '/payment';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainNavigator(),
    profile: (context) => const ProfileScreen(),
    payment: (context) => const PaymentScreen(),
  };
}
