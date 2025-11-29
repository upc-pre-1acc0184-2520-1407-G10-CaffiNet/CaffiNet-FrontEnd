import 'dart:convert';

class RoutePreferencesModel {
  final String algorithm; 
  final double userLat;
  final double userLng;
  // El mapa de filtros se pasa directamente para mayor flexibilidad en el backend
  final Map<String, dynamic> filters; 

  const RoutePreferencesModel({
    required this.algorithm,
    required this.userLat,
    required this.userLng,
    required this.filters,
  });

  // Método para convertir el objeto Dart a JSON para el POST
  String toJson() {
    return json.encode({
      'algorithm': algorithm,
      'user_location': {
        'latitude': userLat,
        'longitude': userLng,
      },
      'filters': filters,
    });
  }
  




}