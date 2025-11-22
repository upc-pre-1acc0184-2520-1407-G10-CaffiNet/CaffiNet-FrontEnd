

abstract class DiscoverEvent {}

/// Evento disparado cuando el usuario interactúa con los filtros o selecciona el algoritmo.
/// Este evento actualiza temporalmente las preferencias antes del cálculo final.
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