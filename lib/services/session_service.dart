import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import 'auth_service.dart';

class SessionService {
  // Iniciar sesión de carga
  static Future<Map<String, dynamic>?> startSession({
    required int idCargador,
    required int durationMinutes,
    String tipoCarga = 'lenta',
  }) async {
    try {
      print('📡 Iniciando sesión de carga...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return null;
      }

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/api/sessions/start'),
            headers: {
              ...ApiConstants.headers,
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'id_cargador': idCargador,
              'duration_minutes': durationMinutes,
              'tipo_carga': tipoCarga,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout al iniciar sesión');
            },
          );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          print('✅ Sesión iniciada exitosamente');
          print('📊 Datos de sesión: ${body['data']}');
          return body['data'];
        } else {
          print('❌ Error en la respuesta: ${body['message']}');
          return null;
        }
      } else if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        print('⚠️ Error de negocio: ${body['message']}');
        throw Exception(body['message'] ?? 'Cargador no disponible');
      } else if (response.statusCode == 402) {
        final body = jsonDecode(response.body);
        print('💳 Pago no autorizado: ${body['message']}');
        throw Exception(body['message'] ?? 'Fondos insuficientes');
      } else if (response.statusCode == 503) {
        final body = jsonDecode(response.body);
        print('🔌 Cargador no responde: ${body['message']}');
        throw Exception(body['message'] ?? 'Cargador no disponible');
      } else {
        print('❌ Error al iniciar sesión - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error en startSession: $e');
      rethrow;
    }
  }

  // Detener sesión de carga manualmente
  static Future<Map<String, dynamic>?> stopSession(int sessionId) async {
    try {
      print('📡 Deteniendo sesión de carga: $sessionId');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return null;
      }

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/api/sessions/stop/$sessionId'),
            headers: {
              ...ApiConstants.headers,
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout al detener sesión');
            },
          );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          print('✅ Sesión detenida exitosamente');
          print('📊 Datos finales: ${body['data']}');
          return body['data'];
        } else {
          print('❌ Error en la respuesta: ${body['message']}');
          return null;
        }
      } else if (response.statusCode == 404) {
        final body = jsonDecode(response.body);
        print('⚠️ Sesión no encontrada: ${body['message']}');
        throw Exception(body['message'] ?? 'Sesión no encontrada');
      } else {
        print('❌ Error al detener sesión - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error en stopSession: $e');
      rethrow;
    }
  }
}
