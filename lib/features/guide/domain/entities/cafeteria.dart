// guide/domain/entities/cafeteria.dart

import 'package:latlong2/latlong.dart';

// Esta entidad representa la cafetería en el dominio de la aplicación.
class Cafeteria {
  final String id;
  final String name;
  final LatLng location;
  // Puedes desglosar LatLng en latitude y longitude si prefieres la entidad más simple,
  // pero usar LatLng de flutter_map aquí es común para simplificar el Usecase.
  
  // Para la presentación del mapa, es útil exponer las coordenadas directamente:
  double get latitude => location.latitude;
  double get longitude => location.longitude;

  Cafeteria({
    required this.id,
    required this.name,
    required this.location,
  });
}