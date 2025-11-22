import 'package:caffinet_app_flutter/features/guide/domain/entities/cafeteria.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// Clase base abstracta para todos los estados del BLoC
abstract class GuideState extends Equatable {
  const GuideState();

  @override
  List<Object> get props => [];
}

// 1. Estado inicial o cuando la data se está fetchando (Cargando)
class GuideInitial extends GuideState {}

class GuideLoading extends GuideState {}

// 2. Estado de datos cargados exitosamente
// Contiene la data final que necesita el widget para renderizar el mapa.
class GuideLoaded extends GuideState {
  final Cafeteria cafeteria;
  final LatLng userLocation;
  final String userLocationName;

  const GuideLoaded({
    required this.cafeteria,
    required this.userLocation,
    required this.userLocationName,
  });

  // Equatable nos ayuda a que Flutter sepa cuándo el estado realmente cambió
  @override
  List<Object> get props => [cafeteria, userLocation, userLocationName];
}

// 3. Estado de error
// Contiene un mensaje para mostrar al usuario.
class GuideError extends GuideState {
  final String message;

  const GuideError(this.message);

  @override
  List<Object> get props => [message];
}