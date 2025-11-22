// guide/data/datasources/guide_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http; 
import 'package:latlong2/latlong.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants.dart';
import '../models/cafeteria_model.dart';

// --- Contrato del DataSource ---
abstract class GuideRemoteDataSource {
  Future<CafeteriaModel> getCafeteriaDetail(String cafeteriaId);
  Future<LatLng> getCurrentUserLocation();
}

// --- Implementación del DataSource ---
class GuideRemoteDataSourceImpl implements GuideRemoteDataSource {
  // Ahora esperamos tu ApiClient, resolviendo el error de asignación de tipo.
  final ApiClient client; 
  final String baseUrl = BASE_URL; 

  GuideRemoteDataSourceImpl({required this.client});

  @override
  Future<CafeteriaModel> getCafeteriaDetail(String cafeteriaId) async {
    // La llamada usa el método 'get' de tu ApiClient. 
    // Se envía solo el path, ya que el ApiClient debe manejar el BASE_URL.
    final response = await client.get(
      '/cafeterias/cafeterias/$cafeteriaId', 
      // Si tu ApiClient no maneja los headers por defecto, mantenlos:
      headers: {'Content-Type': 'application/json'},
    );

    // Asumimos que client.get devuelve un objeto http.Response
    if (response.statusCode == 200) {
      return CafeteriaModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Cafetería no encontrada.');
    } else {
      throw Exception('Fallo al cargar el detalle de la cafetería (Código: ${response.statusCode}).');
    }
  }

  @override
  Future<LatLng> getCurrentUserLocation() async {
    // --- SIMULACRO DE UBICACIÓN DEL USUARIO ---
    await Future.delayed(const Duration(milliseconds: 500)); 
    return LatLng(-12.0463, -77.0428); 
  }
}