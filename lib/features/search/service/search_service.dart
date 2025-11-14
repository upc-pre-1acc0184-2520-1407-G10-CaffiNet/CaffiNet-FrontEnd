import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../search/models/search_models.dart';

class SearchService {
 
  static const String baseUrl = 'http://127.0.0.1:8000';

  final http.Client _client = http.Client();

  Future<List<SearchResult>> getCafeterias() async {
    final uri = Uri.parse('$baseUrl/cafeterias/cafeterias/');
    final resp = await _client.get(uri);

   
    print('GET $uri -> ${resp.statusCode}');
   

    if (resp.statusCode != 200) {
      throw Exception('Failed to load cafeterias (${resp.statusCode})');
    }

    final decoded = json.decode(resp.body);

    
    if (decoded is! List) {
      throw Exception(
        'Formato inesperado de respuesta: ${decoded.runtimeType}',
      );
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    CafeTier _tierFrom(dynamic v) {
      final s = (v ?? '').toString().toLowerCase();
      switch (s) {
        case 'gold':
          return CafeTier.gold;
        case 'silver':
          return CafeTier.silver;
        default:
          return CafeTier.bronze;
      }
    }

    bool _isOpen(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'open' || s == 'abierto';
      }
      return false;
    }

    //  Normaliza coordenadas gigantes 
    double _normalizeCoord(double v) {
      
      if (v.abs() <= 180) return v;

      
      return v / 1e7;
    }

    final results = decoded.map<SearchResult>((dynamic j) {
      final map = j as Map<String, dynamic>;

      
      final bool petFriendly = map['pet_friendly'] == true;
      final bool hasWifi = map['wifi'] == true;
      final bool hasReservations =
          map['reservations'] == true || map['reservas'] == true;
      final bool hasParking =
          map['parking'] == true || map['estacionamiento'] == true;
      final bool hasMusic =
          (map['tipo_musica'] ?? map['music'])?.toString().isNotEmpty == true;

      // Tags visibles en la UI 
      final List<String> tags = [
        if (petFriendly) 'Pet-friendly',
        if (hasWifi) 'Free Wi-Fi',
        if (hasReservations) 'Reservations',
        if (hasParking) 'Parking Available',
        if (hasMusic) 'Music',
      ];

      
      final estilo = map['estilo_decorativo'] ?? map['restilo_decorativo'];
      if (estilo != null && estilo.toString().isNotEmpty) {
        tags.add(estilo.toString());
      }

      // URL de imagen segura 
      final String? thumbnail =
          (map['imagen'] as String?)?.isNotEmpty == true
              ? map['imagen'] as String
              : null;

      //  Coordenadas desde el backend
      final double rawLatitude =
          _toDouble(map['latitude'] ?? map['latitud']); 
      final double rawLongitude =
          _toDouble(map['longitude'] ?? map['longitud']);

      //  Coordenadas normalizadas para que estén en rango válido
      final double latitude = _normalizeCoord(rawLatitude);
      final double longitude = _normalizeCoord(rawLongitude);

      return SearchResult(
        id: (map['id'] ?? map['cafeteria_id']).toString(),
        name: map['nombre'] ?? map['name'] ?? 'Cafetería',
        address: map['direccion'] ?? map['address'] ?? '',
        rating: _toDouble(map['rating'] ?? map['promedio']),
        ratingCount: _toInt(map['rating_count'] ?? map['cantidad']),
        distanceMi: _toDouble(map['distance_mi']),
        tags: tags,
        status: _isOpen(map['abierto']) ? OpenStatus.open : OpenStatus.closed,
        tier: _tierFrom(map['tier']),
        thumbnail: thumbnail,
        petFriendly: petFriendly,
        hasWifi: hasWifi,
        hasReservations: hasReservations,
        hasParking: hasParking,
        hasMusic: hasMusic,
        latitude: latitude,
        longitude: longitude,
      );
    }).toList();

    print('Cafeterías parseadas: ${results.length}');
    return results;
  }

  ///  Obtiene el horario de una cafetería usando /horarios/{cafeteria_id}
  
  Future<CafeteriaSchedule?> getCafeteriaHorario(String cafeteriaId) async {
    final uri = Uri.parse('$baseUrl/horarios/$cafeteriaId');
    final resp = await _client.get(uri);

    print('GET $uri -> ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return CafeteriaSchedule.fromJson(data);
    }

    if (resp.statusCode == 404) {
      // No tiene horario registrado
      return null;
    }

    throw Exception('Failed to load horario (${resp.statusCode})');
  }

  Future<List<dynamic>> getCafeteriaCalificaciones(String cafeteriaId) async {
    final uri = Uri.parse('$baseUrl/calificaciones/$cafeteriaId');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load calificaciones (${resp.statusCode})');
    }
    return json.decode(resp.body) as List<dynamic>;
  }
}
