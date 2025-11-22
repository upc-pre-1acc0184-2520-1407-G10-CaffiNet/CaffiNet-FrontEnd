// lib/features/discover/domain/usecases/get_optimal_route_usecase.dart

import '../entities/optimal_route_result.dart';
import '../repositories/discover_repository.dart';

/// Clase que encapsula todas las preferencias y la ubicación del usuario
/// necesarias para el cálculo de la ruta.
class RoutePreferences {
  final String algorithm; // Ej: 'Dijkstra', 'Floyd-Warshall'
  final double userLat;
  final double userLng;
  /// Un mapa que contiene todas las selecciones del usuario (Tags, Precio, Vegano, etc.).
  final Map<String, dynamic> filters; 

  const RoutePreferences({
    required this.algorithm,
    required this.userLat,
    required this.userLng,
    required this.filters,
  });
}

