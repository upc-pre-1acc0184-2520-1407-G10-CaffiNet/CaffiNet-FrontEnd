import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result.dart'; 
import 'package:latlong2/latlong.dart';

class OptimalRouteResultModel extends OptimalRouteResult {
  const OptimalRouteResultModel({
    required super.orderedCafeterias,
    required super.selectedAlgorithm,
    required super.bigONotation,
    required super.processingTime,
    super.realRoutePoints = const [],
  });

  factory OptimalRouteResultModel.fromJson(Map<String, dynamic> json) {
    // 🔍 DEBUG: Imprimir JSON recibido del backend
    print('🔍 Backend Response (Raw JSON):');
    print(json.toString());
    print('');
    
    // Mapea la lista de resultados de cafeterías
    final List<CafeRouteItemModel> cafeterias = 
        (json['ordered_cafeterias'] as List)
        .map((e) => CafeRouteItemModel.fromJson(e))
        .toList();
    
    print('✅ Cafeterías parseadas: ${cafeterias.length}');
    for (var i = 0; i < cafeterias.length && i < 3; i++) {
      final c = cafeterias[i];
      print('   Café #${i+1}: ${c.name} (${c.latitude}, ${c.longitude})');
    }
    print('');

    // Parseo defensivo de puntos de ruta reales si vienen del Backend/OSRM
    final List<LatLng> realRoutePoints = [];
    if (json.containsKey('real_route_points') && json['real_route_points'] is List) {
      final rawPoints = json['real_route_points'] as List;
      print('🛣️ Real Route Points encontrados: ${rawPoints.length}');
      for (final p in rawPoints) {
        try {
          if (p is List && p.length >= 2) {
            final a = (p[0] as num).toDouble();
            final b = (p[1] as num).toDouble();
            // Heurística: si el primer valor está en rango de latitud lo usamos como lat
            if (a.abs() <= 90 && b.abs() <= 180) {
              realRoutePoints.add(LatLng(a, b));
            } else if (b.abs() <= 90 && a.abs() <= 180) {
              // Swap si parece [lon, lat]
              realRoutePoints.add(LatLng(b, a));
            }
          } else if (p is Map) {
            double? lat;
            double? lon;
            if (p.containsKey('lat')) lat = (p['lat'] as num).toDouble();
            if (p.containsKey('latitude')) lat ??= (p['latitude'] as num?)?.toDouble();
            if (p.containsKey('lng')) lon = (p['lng'] as num).toDouble();
            if (p.containsKey('lon')) lon ??= (p['lon'] as num?)?.toDouble();
            if (p.containsKey('longitude')) lon ??= (p['longitude'] as num?)?.toDouble();

            if (lat != null && lon != null) {
              if (lat.abs() <= 90 && lon.abs() <= 180) {
                realRoutePoints.add(LatLng(lat, lon));
              } else if (lon.abs() <= 90 && lat.abs() <= 180) {
                realRoutePoints.add(LatLng(lon, lat));
              }
            }
          }
        } catch (_) {
          // Omite puntos malformados
        }
      }
      print('✅ Real Route Points parseados: ${realRoutePoints.length}');
    } else {
      print('⚠️ No se encontraron real_route_points en la respuesta');
    }
    print('');

    return OptimalRouteResultModel(
      orderedCafeterias: cafeterias,
      selectedAlgorithm: json['selected_algorithm'] as String,
      bigONotation: json['big_o_notation'] as String,
      // La duración se recibe como milisegundos (int) y se convierte a Duration
      processingTime: Duration(milliseconds: json['processing_time_ms'] as int),
      realRoutePoints: realRoutePoints,
    );
  }
}

class CafeRouteItemModel extends CafeRouteItem {
  const CafeRouteItemModel({
    required super.cafeteriaId,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.optimalCost,
    required super.distanceKm,
  });

  factory CafeRouteItemModel.fromJson(Map<String, dynamic> json) {
    // Lee valores crudos
    double lat = (json['latitude'] as num).toDouble();
    double lon = (json['longitude'] as num).toDouble();

    // Heurística defensiva: si lat fuera de rango [-90,90] pero lon está en ese rango, swap
    if ((lat.abs() > 90 && lon.abs() <= 90) || (lat.abs() > 180)) {
      final tmp = lat;
      lat = lon;
      lon = tmp;
    }

    return CafeRouteItemModel(
      cafeteriaId: json['cafeteria_id'] as int,
      name: json['name'] as String,
      latitude: lat,
      longitude: lon,
      optimalCost: (json['optimal_cost'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }
}



