// guide/domain/repositories/guide_repository.dart

import '../entities/cafeteria.dart';
import 'package:latlong2/latlong.dart';

// Define las operaciones que el Usecase necesita.
abstract class GuideRepository {
  // Obtiene los detalles de una cafetería específica.
  Future<Cafeteria> getCafeteriaDetail(String cafeteriaId);

  // Obtiene la ubicación actual del usuario.
  Future<LatLng> getUserLocation();
}