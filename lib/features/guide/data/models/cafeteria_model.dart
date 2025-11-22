import 'package:caffinet_app_flutter/features/guide/domain/entities/cafeteria.dart';
import 'package:latlong2/latlong.dart';

class CafeteriaModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  CafeteriaModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor para crear el modelo desde un mapa JSON
  factory CafeteriaModel.fromJson(Map<String, dynamic> json) {
    // 1. OBTENER EL VALOR DE LA API Y CONVERTIR A DOUBLE
    // El JSON devuelve un entero muy grande para la latitud/longitud. 
    // Lo leemos como 'num' para manejar int o double y luego lo convertimos a double.
    // Además, lo dividimos por 1,000,000 para obtener las coordenadas geográficas reales.
    final num rawLatitude = json['latitude'] as num;
    final num rawLongitude = json['longitude'] as num;
    
    // Si tu backend usa el formato estándar (ej. -13.5146702), quita la división. 
    // Asumiendo que el formato es incorrecto, lo dividimos entre 1,000,000
    // para obtener valores cercanos a -13 y -71 (coordenadas de Perú).
    const double coordinateScale = 10000000.0; 

    return CafeteriaModel(
      // 1. CORRECCIÓN ID: Usar el nombre exacto 'cafeteria_id'
      id: json['cafeteria_id'] as int, 
      
      // 2. CORRECCIÓN NOMBRE: Usar el nombre exacto 'name' (siempre que coincida)
      name: json['name'] as String,
      
      // 3. CORRECCIÓN COORDENADAS: Lectura flexible y conversión
      latitude: rawLatitude.toDouble() / coordinateScale,
      longitude: rawLongitude.toDouble() / coordinateScale,
    );
  }

  // Método para convertir el Modelo de Data en una Entidad de Domain
  Cafeteria toEntity() {
    return Cafeteria(
      id: id.toString(), 
      name: name,
      location: LatLng(latitude, longitude),
    );
  }
}