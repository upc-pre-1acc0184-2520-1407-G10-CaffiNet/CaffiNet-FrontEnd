// guide/domain/usecases/get_guide_data.dart

import '../entities/cafeteria.dart';
import '../repositories/guide_repository.dart';
import 'package:latlong2/latlong.dart';

// Clase para empaquetar los datos que devolverá el Caso de Uso (Cafetería + Ubicación).
class GuideData {
  final Cafeteria cafeteria;
  final LatLng userLocation;
  final String userLocationName;

  GuideData({
      required this.cafeteria, 
      required this.userLocation,
      required this.userLocationName, 
  });
}

class GetGuideData {
  final GuideRepository repository;

  GetGuideData(this.repository);

  // El método 'call' ejecuta la lógica.
  // Recibe el ID de la cafetería y devuelve los datos combinados.
  Future<GuideData> call(String cafeteriaId) async {
    // Usamos Future.wait para hacer las llamadas de red y ubicación concurrentemente,
    // mejorando el rendimiento.
    final results = await Future.wait([
      repository.getCafeteriaDetail(cafeteriaId),
      repository.getUserLocation(),
    ]);
    
    final cafeteria = results[0] as Cafeteria;
    final userLocation = results[1] as LatLng;
    
// 🌍 SIMULACIÓN DE LA DIRECCIÓN: Aquí es donde se haría la geocodificación inversa real.
    // Usamos una dirección fija para la ubicación simulada (-12.0463, -77.0428).
    const String simulatedUserAddress = 'Av. Garcilaso de la Vega 1337, Lima'; 

    return GuideData(
    cafeteria: cafeteria,
    userLocation: userLocation,
    userLocationName: simulatedUserAddress
    );
  }
}