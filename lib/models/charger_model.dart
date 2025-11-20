class ChargerModel {
  final int idCargador;
  final int idEstacion;
  final String tipoCarga;
  final String capacidadKw;
  final String estado;
  final DateTime? fechaInstalacion;
  final String? firmwareVersion;

  ChargerModel({
    required this.idCargador,
    required this.idEstacion,
    required this.tipoCarga,
    required this.capacidadKw,
    required this.estado,
    this.fechaInstalacion,
    this.firmwareVersion,
  });

  bool get isAvailable => estado.toLowerCase() == 'disponible';
  bool get isRapida => tipoCarga.toLowerCase() == 'rapida';
  bool get isLenta => tipoCarga.toLowerCase() == 'lenta';

  factory ChargerModel.fromJson(Map<String, dynamic> json) {
    return ChargerModel(
      idCargador: json['id_cargador'] ?? 0,
      idEstacion: json['id_estacion'] ?? 0,
      tipoCarga: json['tipo_carga'] ?? '',
      capacidadKw: json['capacidad_kw']?.toString() ?? '0.00',
      estado: json['estado'] ?? 'desconocido',
      fechaInstalacion:
          json['fecha_instalacion'] != null
              ? DateTime.tryParse(json['fecha_instalacion'])
              : null,
      firmwareVersion: json['firmware_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cargador': idCargador,
      'id_estacion': idEstacion,
      'tipo_carga': tipoCarga,
      'capacidad_kw': capacidadKw,
      'estado': estado,
      'fecha_instalacion': fechaInstalacion?.toIso8601String(),
      'firmware_version': firmwareVersion,
    };
  }
}
