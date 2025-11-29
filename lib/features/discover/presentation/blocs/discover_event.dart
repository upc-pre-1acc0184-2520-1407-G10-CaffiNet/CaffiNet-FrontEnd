
abstract class DiscoverEvent {}

/// Evento disparado cuando el usuario interactúa con los filtros o selecciona el algoritmo.
class PreferencesUpdated extends DiscoverEvent {
  final Map<String, dynamic> currentFilters;
  final String selectedAlgorithm;

  PreferencesUpdated({
    required this.currentFilters,
    required this.selectedAlgorithm,
  });
}

/// Evento disparado cuando el usuario hace clic en el botón "Calcular Ruta Óptima".
class CalculateOptimalRoute extends DiscoverEvent {
  final double userLat;
  final double userLng;

  CalculateOptimalRoute({
    required this.userLat,
    required this.userLng,
  });
}

/// 💡 NUEVO Evento para solicitar las últimas preferencias válidas.
class RetrieveLastPreferences extends DiscoverEvent {}

class CountryChanged extends DiscoverEvent {
  final String newCountryCode; // 'PE' o 'CO'

  CountryChanged({required this.newCountryCode});
}