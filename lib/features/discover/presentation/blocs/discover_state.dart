import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';

abstract class DiscoverState {
  // 💡 Base para acceder a las preferencias desde cualquier estado si es necesario
  abstract final RoutePreferences currentPreferences;
}

/// Estado inicial: El usuario está viendo los filtros, sin haber calculado nada.
class DiscoverInitial extends DiscoverState {
  @override
  final RoutePreferences currentPreferences; 

  DiscoverInitial({required this.currentPreferences});
}

/// Estado de carga mientras el Backend calcula el grafo.
class DiscoverLoading extends DiscoverState {
  // Usa las últimas preferencias guardadas, o un valor por defecto
  @override
  final RoutePreferences currentPreferences = RoutePreferences(algorithm: 'Dijkstra', userLat: 0.0, userLng: 0.0, filters: {});
}

/// Estado de éxito: La ruta se calculó y se obtuvieron los resultados.
class DiscoverSuccess extends DiscoverState {
  final OptimalRouteResult result;
  // 💡 NUEVO: Guarda las preferencias usadas para recalcular.
  @override
  final RoutePreferences currentPreferences; 

  DiscoverSuccess({required this.result, required this.currentPreferences});
}

/// Estado de error: Ocurrió un fallo en el cálculo o la red.
class DiscoverError extends DiscoverState {
  final String message;
  // Usa las últimas preferencias guardadas, o un valor por defecto
  @override
  final RoutePreferences currentPreferences = RoutePreferences(algorithm: 'Dijkstra', userLat: 0.0, userLng: 0.0, filters: {});

  DiscoverError({required this.message});
}