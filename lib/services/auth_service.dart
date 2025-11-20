import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _stripeCustomerIdKey = 'stripe_customer_id';
  static const String _nfcUidKey = 'nfc_uid';

  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null;
    } catch (e) {
      print('Error al verificar autenticación: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> register(
    String nombre,
    String apellidoPaterno,
    String apellidoMaterno,
    String email,
    String password,
  ) async {
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
        'data': responseData['data'],
      };
    } catch (e) {
      print('Error durante el registro: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('Intentando login con email: $email');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: ApiConstants.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['data']['token']);
          await prefs.setString(_userKey, jsonEncode(data['data']['user']));

          // Guardar stripe_customer_id si está disponible
          if (data['data']['user'] != null &&
              data['data']['user']['stripe_customer_id'] != null) {
            await saveStripeCustomerId(
              data['data']['user']['stripe_customer_id'],
            );
            print('✅ Stripe Customer ID guardado desde login');
          }

          return {
            'success': true,
            'message': 'Login exitoso',
            'data': data['data'],
          };
        }
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Credenciales inválidas',
        'data': null,
      };
    } catch (e) {
      print('Error durante el login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'data': null,
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
        headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
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
    await prefs.remove(_stripeCustomerIdKey);
  }

  // Guardar el token de autenticación
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token almacenado correctamente: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error al almacenar token: $e');
    }
  }

  // Obtener el token de autenticación
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        print('✅ Token recuperado correctamente: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ No hay token almacenado');
      }
      return token;
    } catch (e) {
      print('❌ Error al recuperar token: $e');
      return null;
    }
  }

  // Guardar el Stripe Customer ID
  static Future<void> saveStripeCustomerId(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stripeCustomerIdKey, customerId);
      print('✅ Stripe Customer ID almacenado correctamente: $customerId');
    } catch (e) {
      print('❌ Error al almacenar Stripe Customer ID: $e');
    }
  }

  // Obtener el Stripe Customer ID
  static Future<String?> getStripeCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString(_stripeCustomerIdKey);
      if (customerId != null) {
        print('✅ Stripe Customer ID recuperado correctamente: $customerId');
      } else {
        print('⚠️ No hay Stripe Customer ID almacenado');
      }
      return customerId;
    } catch (e) {
      print('❌ Error al recuperar Stripe Customer ID: $e');
      return null;
    }
  }

  // Guardar el NFC UID
  static Future<void> saveNfcUid(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nfcUidKey, uid);
      print('✅ NFC UID almacenado correctamente: $uid');
    } catch (e) {
      print('❌ Error al almacenar NFC UID: $e');
    }
  }

  // Obtener el NFC UID
  static Future<String?> getNfcUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_nfcUidKey);
      if (uid != null) {
        print('✅ NFC UID recuperado correctamente: $uid');
      } else {
        print('⚠️ No hay NFC UID almacenado');
      }
      return uid;
    } catch (e) {
      print('❌ Error al recuperar NFC UID: $e');
      return null;
    }
  }
}
