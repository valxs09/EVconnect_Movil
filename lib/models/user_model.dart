class User {
  final int idUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final double saldoVirtual;
  final DateTime fechaRegistro;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.saldoVirtual,
    required this.fechaRegistro,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
     idUsuario: json['id_usuario'] as int,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellido_paterno'] as String,
      apellidoMaterno: json['apellido_materno'] as String,
      email: json['email'] as String,
      saldoVirtual: double.tryParse(json['saldo_virtual'].toString()) ?? 0.0,
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}