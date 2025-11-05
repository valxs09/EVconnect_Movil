import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';

  // Credenciales fijas para simulación
  static const String _mockEmail = 'admin@gmail.com';
  static const String _mockPassword = '12345678';

  // Login simulado
  static Future<bool> login(String email, String password) async {
    if (email == _mockEmail && password == _mockPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);
      return true;
    }
    return false;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Obtener email del usuario actual
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Simulación de recuperación de contraseña
  static Future<bool> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 2)); // Simular delay de red
    return email.isNotEmpty; // Simular éxito si el email no está vacío
  }
}
