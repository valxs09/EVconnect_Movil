import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<bool> login(String email, String password) async {
    try {
      // TODO: Implementar la llamada real a la API
      await Future.delayed(const Duration(seconds: 2)); // Simular delay de red
      
      // Simulamos un usuario de prueba
      final testUser = {
        'id_usuario': 1,
        'nombre': 'Usuario',
        'apellido_paterno': 'Demo',
        'apellido_materno': 'Test',
        'email': email,
        'saldo_virtual': 0.0,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      // Guardamos los datos del usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(testUser));
      await prefs.setString(_tokenKey, 'test_token');

      return true;
    } catch (e) {
      print('Error durante el login: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error durante el logout: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      
      if (userString != null) {
        final userMap = jsonDecode(userString) as Map<String, dynamic>;
        return User(
          idUsuario: userMap['id_usuario'],
          nombre: userMap['nombre'],
          apellidoPaterno: userMap['apellido_paterno'],
          apellidoMaterno: userMap['apellido_materno'],
          email: userMap['email'],
          saldoVirtual: userMap['saldo_virtual'].toDouble(),
          fechaRegistro: DateTime.parse(userMap['fecha_registro']),
        );
      }
      return null;
    } catch (e) {
      print('Error al obtener el usuario actual: $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null;
    } catch (e) {
      return false;
    }
  }
}