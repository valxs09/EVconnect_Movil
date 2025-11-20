import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/payment_card_model.dart';
import 'auth_service.dart';

class PaymentService {
  // Obtener todos los métodos de pago del usuario
  static Future<List<PaymentCardModel>> getPaymentMethods() async {
    try {
      print('📡 Obteniendo métodos de pago del usuario...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return [];
      }

      final stripeCustomerId = await AuthService.getStripeCustomerId();
      if (stripeCustomerId == null) {
        print('⚠️ No hay stripe_customer_id almacenado');
        // Intentar obtenerlo del perfil del usuario
        final user = await AuthService.getCurrentUser();
        if (user?.stripeCustomerId != null) {
          await AuthService.saveStripeCustomerId(user!.stripeCustomerId!);
          print(
            '✅ Stripe Customer ID recuperado del perfil: ${user.stripeCustomerId}',
          );
        } else {
          print('❌ No se pudo obtener el stripe_customer_id');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentMethods}'),
        headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');
      print('📊 Token usado: ${token.substring(0, 20)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> cardsJson = data['data'];
          final cards =
              cardsJson
                  .map((cardJson) => PaymentCardModel.fromJson(cardJson))
                  .toList();

          print('✅ ${cards.length} métodos de pago obtenidos correctamente');
          return cards;
        } else {
          print('⚠️ Respuesta sin datos de tarjetas');
          return [];
        }
      } else {
        print('❌ Error al obtener métodos de pago: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en getPaymentMethods: $e');
      return [];
    }
  }

  // Agregar un nuevo método de pago
  static Future<Map<String, dynamic>> addPaymentMethod({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    required String cardholderName,
  }) async {
    try {
      print('📡 Agregando nuevo método de pago...');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentMethods}'),
        headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'card_number': cardNumber,
          'exp_month': expMonth,
          'exp_year': expYear,
          'cvc': cvc,
          'cardholder_name': cardholderName,
        }),
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Método de pago agregado correctamente');
        return {
          'success': true,
          'message': data['message'] ?? 'Tarjeta agregada exitosamente',
          'data': data['data'],
        };
      } else {
        print('❌ Error al agregar método de pago');
        return {
          'success': false,
          'message': data['message'] ?? 'Error al agregar tarjeta',
        };
      }
    } catch (e) {
      print('❌ Error en addPaymentMethod: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Establecer tarjeta como principal
  static Future<bool> setPrincipalCard(String cardId) async {
    try {
      print('📡 Estableciendo tarjeta $cardId como principal...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return false;
      }

      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.paymentMethods}/$cardId/principal',
        ),
        headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
      );

      print('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Tarjeta establecida como principal');
        return true;
      } else {
        print('❌ Error al establecer tarjeta como principal');
        return false;
      }
    } catch (e) {
      print('❌ Error en setPrincipalCard: $e');
      return false;
    }
  }

  // Eliminar método de pago
  static Future<bool> deletePaymentMethod(String cardId) async {
    try {
      print('📡 Eliminando método de pago $cardId...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No hay token de autenticación');
        return false;
      }

      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.paymentMethods}/$cardId',
        ),
        headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
      );

      print('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Método de pago eliminado');
        return true;
      } else {
        print('❌ Error al eliminar método de pago');
        return false;
      }
    } catch (e) {
      print('❌ Error en deletePaymentMethod: $e');
      return false;
    }
  }
}
