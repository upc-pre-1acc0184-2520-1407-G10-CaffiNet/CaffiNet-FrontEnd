import 'package:caffinet_app_flutter/core/service/osrm_service.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/get_optimal_route_usecase.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'discover_event.dart';
import 'discover_state.dart';
import 'package:latlong2/latlong.dart';

const Distance distance = Distance();

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetOptimalRouteUseCase getOptimalRoute;
  final OSRMService osrmService; 
  
  // 💡 NUEVO: Almacenamiento persistente de las últimas preferencias válidas
  RoutePreferences _lastSuccessfulPreferences = RoutePreferences(
    algorithm: 'Dijkstra',
    userLat: 0.0,
    userLng: 0.0,
    filters: {},
  );


  DiscoverBloc({
    required this.getOptimalRoute,
    required this.osrmService,
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
    on<RetrieveLastPreferences>(_onRetrieveLastPreferences);
    on<CountryChanged>(_onCountryChanged);
  }

  // --- Handlers de Eventos ---

  // 💡 NUEVO HANDLER: Permite a la UI obtener las últimas preferencias usadas (para el caso de éxito)
  void _onRetrieveLastPreferences(
    RetrieveLastPreferences event,
    Emitter<DiscoverState> emit,
  ) {
    emit(DiscoverInitial(currentPreferences: _lastSuccessfulPreferences));
  }


  void _onPreferencesUpdated(
    PreferencesUpdated event,
    Emitter<DiscoverState> emit,
  ) {
    // 1. Obtener las preferencias actuales (sean del estado inicial o de la última ejecución)
    final currentState = state;
    RoutePreferences basePreferences;
    
    if (currentState is DiscoverInitial) {
      basePreferences = currentState.currentPreferences;
    } else {
      // Usamos las últimas preferencias exitosas si no estamos en estado inicial
      basePreferences = _lastSuccessfulPreferences;
    }


    // 2. Fusionar las preferencias: Mantiene la ubicación y fusiona filtros/algoritmo
    final updatedPreferences = RoutePreferences(
      // 💡 Se mantiene la ubicación de basePreferences (que incluye la última ubicación exitosa)
      userLat: basePreferences.userLat,
      userLng: basePreferences.userLng, 
      
      // 💡 Toma el nuevo algoritmo y los nuevos filtros del evento
      algorithm: event.selectedAlgorithm,
      filters: event.currentFilters.isNotEmpty ? event.currentFilters : basePreferences.filters,

    );

    // 3. Emite el estado inicial con las preferencias actualizadas
    emit(DiscoverInitial(currentPreferences: updatedPreferences));
  }


  void _onCountryChanged(
    CountryChanged event,
    Emitter<DiscoverState> emit,
  ) {
    const defaultAlgorithm = 'Dijkstra';
    
    // Coordenadas fijas de Plaza de Bolívar, Bogotá, si es Colombia
    final double lat = (event.newCountryCode == 'CO') ? 4.59806 : 0.0;
    final double lng = (event.newCountryCode == 'CO') ? -74.07609 : 0.0;

    // Reiniciamos las preferencias. Los filtros se vacían, y la ubicación se establece
    // en 0.0 para Perú (será actualizada por Geolocator) o fija para Colombia.
    final updatedPreferences = RoutePreferences(
      algorithm: defaultAlgorithm,
      userLat: lat,
      userLng: lng,
      filters: {}, // Se limpian los filtros al cambiar de país
    );

    // Reiniciamos también el estado de persistencia
    _lastSuccessfulPreferences = updatedPreferences;

    // Emitimos el estado inicial para que la UI se resetee y muestre los filtros
    emit(DiscoverInitial(currentPreferences: updatedPreferences));
  }
  
  void _onCalculateOptimalRoute(
    CalculateOptimalRoute event,
    Emitter<DiscoverState> emit,
  ) async {
    // 1. Tomar las preferencias del estado actual (que ya tienen el algoritmo y filtros)
    final RoutePreferences currentPreferences = state is DiscoverInitial
      ? (state as DiscoverInitial).currentPreferences
      : _lastSuccessfulPreferences; // Fallback

    emit(DiscoverLoading());

    try {
      // 2. Crear las preferencias finales para el cálculo, añadiendo la ubicación del evento
      final preferences = currentPreferences.copyWith(
        userLat: event.userLat,
        userLng: event.userLng,
      );

      // 3. Guardar las preferencias finales en la variable persistente antes del cálculo
      _lastSuccessfulPreferences = preferences;

      // 4. Llamada al Backend (Usecase)
      final optimalResult = await getOptimalRoute(preferences); 


      // ------------------------------------------------------------------
      // 💡 NUEVA VALIDACIÓN DE REGLAS DE NEGOCIO
      // ------------------------------------------------------------------
      
      // Regla 1: Verificar si hay cafeterías en la ruta
      if (optimalResult.orderedCafeterias.isEmpty) {
        emit(DiscoverError(message: '❌ No se encontraron cafeterías con los parámetros seleccionados. Intenta ampliar tus filtros o radio de búsqueda.'));
        return;
      }

      // Regla 2: Verificar que la primera cafetería no esté excesivamente lejos (ej. más de 15 km)
      final userLocation = LatLng(preferences.userLat, preferences.userLng);
      final firstCafe = optimalResult.orderedCafeterias.first;
      final firstCafeLocation = LatLng(firstCafe.latitude, firstCafe.longitude);
      
      // Calcula la distancia en metros, luego convierte a kilómetros
      final double distanceMeters = distance(userLocation, firstCafeLocation); 
      final double distanceKm = distanceMeters / 1000.0;
      
      const double maxDistanceKm = 15.0; // Distancia máxima aceptable
      
      if (distanceKm > maxDistanceKm) {
        final distanceFormatted = distanceKm.toStringAsFixed(1);
        emit(DiscoverError(message: '⚠️ La cafetería más cercana encontrada está a $distanceFormatted km. Esto sugiere que no hay resultados relevantes cerca de tu ubicación o que el filtro es demasiado restrictivo.'));
        return;
      }

      // ------------------------------------------------------------------

      // 5. Extraer y llamar a OSRM para la geometría
      final List<LatLng> cafePoints = optimalResult.orderedCafeterias
          .map((c) => LatLng(c.latitude, c.longitude))
          .toList();

      final realRoutePoints = await osrmService.getRealRoutePolyline(cafePoints);

      // 6. Emitir Éxito con los puntos de ruta enriquecidos
      final finalResult = optimalResult.copyWith(realRoutePoints: realRoutePoints);

      // 7. 💡 ¡CORRECCIÓN CRÍTICA!
      // El estado de éxito ahora lleva la copia de las preferencias usadas.
      emit(DiscoverSuccess(result: finalResult, currentPreferences: preferences));

    } catch (e) {
      emit(DiscoverError(message: 'Error al calcular la ruta: ${e.toString()}'));
    }
  }
}