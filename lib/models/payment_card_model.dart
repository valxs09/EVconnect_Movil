class PaymentCardModel {
  final String id;
  final String brand;
  final String last4;
  final String expMonth;
  final String expYear;
  final bool isPrincipal;

  PaymentCardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isPrincipal = false,
  });

  String get expiry => '$expMonth/$expYear';

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    // Parsear la fecha de expiración "12/2030"
    String expira = json['expira'] ?? '00/0000';
    List<String> parts = expira.split('/');
    String expMonth = parts.isNotEmpty ? parts[0] : '00';
    String expYear =
        parts.length > 1
            ? parts[1].substring(2)
            : '00'; // Últimos 2 dígitos del año

    return PaymentCardModel(
      id: json['payment_method_id'] ?? '',
      brand:
          (json['tipo'] ?? 'Unknown').toString().toUpperCase(), // visa -> VISA
      last4: json['ultimos_digitos'] ?? '0000',
      expMonth: expMonth.padLeft(2, '0'),
      expYear: expYear,
      isPrincipal: json['es_predeterminado'] ?? false,
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
