import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../navigation/main_navigator.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/payments/payment_screen.dart';
import '../screens/reservations/nfc_screen.dart';
import '../screens/reservations/time_screen.dart';
import '../screens/reservations/session_progress_screen.dart';
import '../screens/reservations/summary_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String payment = '/payment';
  static const String nfc = '/nfc';
  static const String time = '/time';
  static const String sessionProgress = '/session-progress';
  static const String summary = '/summary';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainNavigator(),
    profile: (context) => const ProfileScreen(),
    payment: (context) => const PaymentScreen(),
    nfc: (context) => const NFCScreen(),
    time: (context) => const TimeScreen(),
    sessionProgress: (context) => const SessionProgressScreen(),
    summary: (context) => const SummaryScreen(),
  };
}
