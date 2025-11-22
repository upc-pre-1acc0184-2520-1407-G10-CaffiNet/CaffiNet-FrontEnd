import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';

abstract class DiscoverState {}

/// Estado inicial: El usuario está viendo los filtros, sin haber calculado nada.
class DiscoverInitial extends DiscoverState {
  // Guarda las preferencias actuales para que los widgets puedan inicializarse.
  final RoutePreferences currentPreferences; 

  DiscoverInitial({required this.currentPreferences});
}

/// Estado de carga mientras el Backend calcula el grafo.
class DiscoverLoading extends DiscoverState {}

/// Estado de éxito: La ruta se calculó y se obtuvieron los resultados.
class DiscoverSuccess extends DiscoverState {
  final OptimalRouteResult result;

  DiscoverSuccess({required this.result});
}

/// Estado de error: Ocurrió un fallo en el cálculo o la red.
class DiscoverError extends DiscoverState {
  final String message;

  DiscoverError({required this.message});
}