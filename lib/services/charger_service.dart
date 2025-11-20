import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/charger_model.dart';

class ChargerService {
  /// Obtener todos los cargadores de una estación específica
  static Future<List<ChargerModel>> getChargersByStation(int estacionId) async {
    try {
      print('📡 Obteniendo cargadores de la estación $estacionId...');

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.chargers}/estacion/$estacionId',
        ),
        headers: ApiConstants.headers,
      );

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> chargersJson = data['data'];
          final chargers =
              chargersJson
                  .map((chargerJson) => ChargerModel.fromJson(chargerJson))
                  .toList();

          print('✅ ${chargers.length} cargadores obtenidos correctamente');
          return chargers;
        } else {
          print('⚠️ Respuesta sin datos de cargadores');
          return [];
        }
      } else {
        print('❌ Error al obtener cargadores: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en getChargersByStation: $e');
      return [];
    }
  }

  /// Obtener cargadores disponibles por tipo de carga
  /// [estacionId] - ID de la estación
  /// [tipoCarga] - Tipo de carga: 'rapida' o 'lenta'
  static Future<List<ChargerModel>> getAvailableChargersByType({
    required int estacionId,
    required String tipoCarga,
  }) async {
    try {
      print(
        '📡 Buscando cargadores disponibles tipo "$tipoCarga" en estación $estacionId...',
      );

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chargers}/estacion/$estacionId/disponibles',
      ).replace(queryParameters: {'tipoCarga': tipoCarga});

      final response = await http.get(uri, headers: ApiConstants.headers);

      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> chargersJson = data['data'];
          final chargers =
              chargersJson
                  .map((chargerJson) => ChargerModel.fromJson(chargerJson))
                  .toList();

          print('✅ ${chargers.length} cargadores disponibles encontrados');
          return chargers;
        } else {
          print('⚠️ No hay cargadores disponibles');
          return [];
        }
      } else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        print('⚠️ ${data['message']}');
        return [];
      } else {
        print(
          '❌ Error al obtener cargadores disponibles: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error en getAvailableChargersByType: $e');
      return [];
    }
  }

  /// Obtener solo cargadores disponibles de cualquier tipo
  static Future<List<ChargerModel>> getAvailableChargers(int estacionId) async {
    try {
      final allChargers = await getChargersByStation(estacionId);
      final availableChargers =
          allChargers.where((charger) => charger.isAvailable).toList();

      print(
        '✅ ${availableChargers.length} cargadores disponibles de ${allChargers.length} totales',
      );
      return availableChargers;
    } catch (e) {
      print('❌ Error en getAvailableChargers: $e');
      return [];
    }
  }

  /// Verificar si hay cargadores disponibles de un tipo específico
  static Future<bool> hasAvailableChargers({
    required int estacionId,
    required String tipoCarga,
  }) async {
    final chargers = await getAvailableChargersByType(
      estacionId: estacionId,
      tipoCarga: tipoCarga,
    );
    return chargers.isNotEmpty;
  }
}
