import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/foundation.dart';

class OSRMService {
  final http.Client client; 

  OSRMService({required this.client});

  Future<List<LatLng>> getRealRoutePolyline(List<LatLng> points) async {
    if (points.length < 2) return [];

    // Formato de OSRM: longitude1,latitude1;longitude2,latitude2;...
    final coordinates = points
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    // Endpoint de OSRM para obtener la geometría de la ruta
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$coordinates?geometries=polyline&overview=full');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final routes = jsonResponse['routes'] as List;

        if (routes.isNotEmpty) {
          final encodedPolyline = routes[0]['geometry'] as String;
          
          // 🛑 CORRECCIÓN: Se inicializa PolylinePoints con un apiKey, aunque esté vacío,
          // para satisfacer el constructor requerido por el paquete.
          PolylinePoints polylinePoints = PolylinePoints(apiKey: ""); 
          
          // Decodifica la polilínea codificada por OSRM (que usa el mismo estándar).
        List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);
          // Convierte la lista de PointLatLng (del paquete) a LatLng (de flutter_map).
          return decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
        }
        return [];
      } else {
        // Manejo de códigos de estado de error del servicio OSRM
        if (kDebugMode) {
            print('OSRM: Error ${response.statusCode}. Body: ${response.body}');
        }
        throw Exception('OSRM failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores de red o excepciones generales.
      if (kDebugMode) {
        print('OSRM Service Error de Red/General: $e');
      }
      return []; // Devolvemos lista vacía para no romper el flujo
    }
  }
}