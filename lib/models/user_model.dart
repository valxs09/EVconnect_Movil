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
      saldoVirtual: (json['saldo_virtual'] as num).toDouble(),
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
    );
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
