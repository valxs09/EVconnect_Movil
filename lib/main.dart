import 'package:flutter/material.dart';
import 'package:evconnect/config/theme.dart';
import 'package:evconnect/config/routes.dart';
import 'package:evconnect/screens/auth/login_screen.dart';
import 'package:evconnect/navigation/main_navigator.dart';
import 'package:evconnect/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EvcApp());
}

class EvcApp extends StatelessWidget {
  const EvcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVCONNECT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return snapshot.data == true 
              ? const MainNavigator()
              : const LoginScreen();
        },
      ),
    );
  }
}
