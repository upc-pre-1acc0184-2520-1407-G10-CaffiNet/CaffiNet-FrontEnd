import 'package:caffinet_app_flutter/core/service/osrm_service.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/get_optimal_route_usecase.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'discover_event.dart';
import 'discover_state.dart';
import 'package:latlong2/latlong.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetOptimalRouteUseCase getOptimalRoute;
  final OSRMService osrmService; // SE AÑADE EL SERVICIO OSRM

  DiscoverBloc({
    required this.getOptimalRoute,
    required this.osrmService, // SE AÑADE LA INYECCIÓN
  })
      : super(
            DiscoverInitial(
                currentPreferences: RoutePreferences(
                    algorithm: 'Dijkstra',
                    userLat: 0.0,
                    userLng: 0.0,
                    filters: {},
                ),
            ),
        ) {
    on<PreferencesUpdated>(_onPreferencesUpdated);
    on<CalculateOptimalRoute>(_onCalculateOptimalRoute);
  }

  // --- Handlers de Eventos ---

  void _onPreferencesUpdated(
    PreferencesUpdated event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    final currentPreferences = currentState is DiscoverInitial
        ? currentState.currentPreferences
        : RoutePreferences(algorithm: event.selectedAlgorithm, userLat: 0.0, userLng: 0.0, filters: {});

    final updatedPreferences = RoutePreferences(
      algorithm: event.selectedAlgorithm,
      userLat: currentPreferences.userLat,
      userLng: currentPreferences.userLng,
      filters: event.currentFilters,
    );

    emit(DiscoverInitial(currentPreferences: updatedPreferences));
  }

  void _onCalculateOptimalRoute(
    CalculateOptimalRoute event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentPreferences = state is DiscoverInitial
        ? (state as DiscoverInitial).currentPreferences
        : RoutePreferences(algorithm: 'Dijkstra', userLat: 0.0, userLng: 0.0, filters: {});

    emit(DiscoverLoading());

    try {
      final preferences = RoutePreferences(
        algorithm: currentPreferences.algorithm,
        userLat: event.userLat,
        userLng: event.userLng,
        filters: currentPreferences.filters,
      );

      // 1. Llamada al Backend (Usecase)
      final optimalResult = await getOptimalRoute(preferences); // Devuelve OptimalRouteResult

      // 2. Extraer los puntos de las cafeterías (nodos)
      final List<LatLng> cafePoints = optimalResult.orderedCafeterias
          .map((c) => LatLng(c.latitude, c.longitude))
          .toList();

      // 3. 🌐 Llamada al Servicio OSRM para obtener la geometría curva
      final realRoutePoints = await osrmService.getRealRoutePolyline(cafePoints);

      // 4. ✅ Emitir Éxito con los puntos de ruta enriquecidos (curvos)
      // Usamos copyWith para añadir los puntos de ruta real.
      final finalResult = optimalResult.copyWith(realRoutePoints: realRoutePoints);

      emit(DiscoverSuccess(result: finalResult));

    } catch (e) {
      // Manejo de excepción que incluye errores de red y OSRM
      emit(DiscoverError(message: 'Error al calcular la ruta: ${e.toString()}'));
    }
  }
}