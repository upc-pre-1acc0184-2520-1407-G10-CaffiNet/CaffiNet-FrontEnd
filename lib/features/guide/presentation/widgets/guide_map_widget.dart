import 'package:caffinet_app_flutter/features/guide/domain/entities/cafeteria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class GuideMapWidget extends StatelessWidget {
  final Cafeteria cafeteria;
  final latlng.LatLng userLocation;

  const GuideMapWidget({
    required this.cafeteria,
    required this.userLocation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Definir los puntos a mostrar
    final cafeteriaLocation = cafeteria.location;

    // 2. Calcular el centro del mapa (punto medio)
    final centerLat = (cafeteriaLocation.latitude + userLocation.latitude) / 2;
    final centerLng = (cafeteriaLocation.longitude + userLocation.longitude) / 2;
    final center = latlng.LatLng(centerLat, centerLng);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0, 
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        )
      ),
      children: [
        // Capa base del mapa
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.your_app',
        ),
        
        // Capa de polilínea
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                cafeteriaLocation,
                userLocation,
              ],
              color: Colors.blue, 
              strokeWidth: 4.0,
              borderStrokeWidth: 1.0,
              borderColor: Colors.white,
            ),
          ],
        ),
        
        // Capa de marcadores
        MarkerLayer(
          markers: [
            // Marcador de la Cafetería
            Marker(
              point: cafeteriaLocation,
              width: 100,
              height: 100,
              child: const Icon(Icons.location_pin, color: Colors.brown, size: 50),
              // *** SE ELIMINA anchorPos/anchor PARA SOLUCIONAR EL ERROR ***
            ),
            // Marcador del Usuario
            Marker(
              point: userLocation,
              width: 100,
              height: 100,
              child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 50),
              // *** SE ELIMINA anchorPos/anchor PARA SOLUCIONAR EL ERROR ***
            ),
          ],
        ),
      ],
    );
  }
}