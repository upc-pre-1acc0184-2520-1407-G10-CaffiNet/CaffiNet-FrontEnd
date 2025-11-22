// lib/features/discover/domain/usecases/get_optimal_route_usecase.dart

// 🛑 Importar RoutePreferences desde su archivo único
import 'route_preferences.dart'; 

import '../entities/optimal_route_result.dart';
import '../repositories/discover_repository.dart';

/// Use Case: Obtener la lista de cafeterías ordenadas por ruta óptima.
class GetOptimalRouteUseCase {
  final DiscoverRepository repository;

 GetOptimalRouteUseCase(this.repository);

  Future<OptimalRouteResult> call(RoutePreferences preferences) {
   return repository.calculateOptimalRoute(preferences);
 }
}