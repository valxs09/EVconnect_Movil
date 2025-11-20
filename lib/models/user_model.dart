class User {
  final int idUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final String? nfcUid;
  final double saldoVirtual;
  final String? stripeCustomerId;
  final bool tarjetaVerificada;
  final DateTime fechaRegistro;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    this.nfcUid,
    required this.saldoVirtual,
    this.stripeCustomerId,
    required this.tarjetaVerificada,
    required this.fechaRegistro,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
  String get nombreApellido => '$nombre $apellidoPaterno';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['id_usuario'] as int,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellido_paterno'] as String,
      apellidoMaterno: json['apellido_materno'] as String,
      email: json['email'] as String,
      nfcUid: json['nfc_uid'] as String?,
      saldoVirtual: double.tryParse(json['saldo_virtual'].toString()) ?? 0.0,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      tarjetaVerificada: json['tarjeta_verificada'] as bool? ?? false,
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}
