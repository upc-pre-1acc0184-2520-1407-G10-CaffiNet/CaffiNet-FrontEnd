
import 'package:latlong2/latlong.dart';

class OptimalRouteResult {
  /// Lista de cafeterías ordenadas de la más conveniente a la menos conveniente.
  final List<CafeRouteItem> orderedCafeterias; 
  
  /// Nombre del algoritmo usado (Dijkstra, Floyd-Warshall, Bellman-Ford).
  final String selectedAlgorithm; 
  
  /// La complejidad temporal del algoritmo (Ej: O(E + V log V)).
  final String bigONotation; 
  
  /// Tiempo real que tardó el Backend en ejecutar el algoritmo.
  final Duration processingTime; 
  final List<LatLng> realRoutePoints;
  

  const OptimalRouteResult({
    required this.orderedCafeterias,
    required this.selectedAlgorithm,
    required this.bigONotation,
    required this.processingTime,
    this.realRoutePoints = const [],
  });

  OptimalRouteResult copyWith({
    List<CafeRouteItem>? orderedCafeterias,
    String? selectedAlgorithm,
    String? bigONotation,
    Duration? processingTime,
    List<LatLng>? realRoutePoints, // El campo que actualiza el BLoC
  }) {
    return OptimalRouteResult(
      // Copia los valores antiguos si el nuevo valor es null
      orderedCafeterias: orderedCafeterias ?? this.orderedCafeterias,
      selectedAlgorithm: selectedAlgorithm ?? this.selectedAlgorithm,
      bigONotation: bigONotation ?? this.bigONotation,
      processingTime: processingTime ?? this.processingTime,
      // Sobrescribe realRoutePoints con los puntos de OSRM o usa los antiguos si no se pasan
      realRoutePoints: realRoutePoints ?? this.realRoutePoints, 
    );
  }
}

/// Representa una sola cafetería en la lista de resultados de la ruta óptima.
class CafeRouteItem {
  final int cafeteriaId;
  final String name;
  final double latitude;
  final double longitude;
  
  /// El coste total calculado por el algoritmo (combina distancia y penalizaciones/beneficios por preferencias).
  final double optimalCost; 
  
  /// La distancia física en kilómetros desde la ubicación del usuario.
  final double distanceKm;

  const CafeRouteItem({
    required this.cafeteriaId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.optimalCost,
    required this.distanceKm,
  });
}

