import 'package:caffinet_app_flutter/core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/optimal_route_result_model.dart';
import '../models/route_preferences_model.dart';

// URL base de tu API
const String _baseUrl = BASE_URL; // Asegúrate de actualizar con tu IP/Dominio real

abstract class DiscoverRemoteDataSource {
  // Nuevo endpoint en el Backend que ejecuta el algoritmo
  Future<OptimalRouteResultModel> calculateOptimalRoute(RoutePreferencesModel preferences);
}

class DiscoverRemoteDataSourceImpl implements DiscoverRemoteDataSource {
  final http.Client client;

  DiscoverRemoteDataSourceImpl({required this.client});

  @override
  Future<OptimalRouteResultModel> calculateOptimalRoute(
      RoutePreferencesModel preferences) async {
    // La URL asumirá un endpoint en tu backend para el cálculo de rutas
    final url = Uri.parse('$_baseUrl/discover/optimal_route/'); 

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // Convierte el modelo de preferencias a JSON para el cuerpo de la petición
        body: preferences.toJson(),
      );

      if (response.statusCode == 200) {
        // La respuesta del servidor es el resultado del algoritmo
        final data = json.decode(response.body);
        return OptimalRouteResultModel.fromJson(data);
      } else {
        // Manejo de errores de HTTP (ej: 404, 500)
        throw Exception('Failed to calculate optimal route. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores de conexión o parsing
      if (kDebugMode) {
        print('Error en calculateOptimalRoute: $e');
      }
      throw Exception('Network error or invalid data format.');
    }
  }
}