// Archivo: lib/models/payment_card_model.dart
class PaymentCardModel {
  final String id; // Mapeado desde 'token_referencia' o 'id'
  final String brand; // Visa, Mastercard...
  final String last4; // Últimos 4 dígitos (visible para el usuario)
  final int expMonth;
  final int expYear;
  final bool isPrincipal; // Mapeado desde 'es_predeterminado'

  PaymentCardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isPrincipal,
  });

  // Genera el texto "12/25" para la UI
  String get expiry {
    String yearStr = expYear.toString();
    String shortYear = yearStr.length >= 4 ? yearStr.substring(2) : '00';
    return '${expMonth.toString().padLeft(2, '0')}/$shortYear';
  }

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    // Lógica para parsear la fecha "6/2030" que manda tu backend
    int parsedMonth = 0;
    int parsedYear = 0;

    if (json['expira'] != null) {
      try {
        final parts = json['expira'].toString().split('/');
        if (parts.length == 2) {
          parsedMonth = int.tryParse(parts[0]) ?? 0;
          parsedYear = int.tryParse(parts[1]) ?? 0;
        }
      } catch (e) {
        print('Error parseando fecha: $e');
      }
    } else {
      // Fallback por si en el futuro cambia a formato separado
      parsedMonth = int.tryParse(json['exp_month']?.toString() ?? '0') ?? 0;
      parsedYear = int.tryParse(json['exp_year']?.toString() ?? '0') ?? 0;
    }

    return PaymentCardModel(
      // Mapeo de todos los nombres posibles de campos
      id: json['payment_method_id'] ?? json['id'] ?? '',
      brand: json['tipo'] ?? json['brand'] ?? 'Tarjeta',
      last4: json['ultimos_digitos'] ?? json['last4'] ?? '0000',
      isPrincipal: json['es_predeterminado'] ?? json['default'] ?? false,
      expMonth: parsedMonth,
      expYear: parsedYear,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'payment_method_id': id,
      'tipo': brand.toLowerCase(),
      'ultimos_digitos': last4,
      'expira': '$expMonth/20$expYear',
      'es_predeterminado': isPrincipal,
    };
  }
}
