
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
  RoutePreferences copyWith({
    String? algorithm,
    double? userLat,
    double? userLng,
    Map<String, dynamic>? filters,
  }) {
    return RoutePreferences(
      // Si el valor pasado no es null, lo usa. Si es null, usa el valor actual (this.algorithm).
      algorithm: algorithm ?? this.algorithm,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      
      // Mantiene el mapa existente si no se proporciona uno nuevo.
      filters: filters ?? this.filters, 
    );
  }

}

