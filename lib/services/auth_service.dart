import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<Map<String, dynamic>> register(String nombre, String apellidoPaterno, 
      String apellidoMaterno, String email, String password) async {
    try {
      print('Intentando registrar usuario con email: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'nombre': nombre,
          'apellido_paterno': apellidoPaterno,
          'apellido_materno': apellidoMaterno,
          'email': email,
          'password': password,
        }),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': responseData['message'] ?? 'Error desconocido',
        'data': responseData['data']
      };
    } catch (e) {
      print('Error durante el registro: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'data': null
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Intentando login con email: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['data']['token']);
          await prefs.setString(_userKey, jsonEncode(data['data']['user']));
          return {
            'success': true,
            'message': 'Login exitoso',
            'data': data['data']
          };
        }
      }
      
      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Credenciales inválidas',
        'data': null
      };
    } catch (e) {
      print('Error durante el login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'data': null
      };
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener el usuario: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}