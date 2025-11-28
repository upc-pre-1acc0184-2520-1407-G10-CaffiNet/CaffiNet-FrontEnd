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

      final String? thumbnail =
          (map['imagen'] as String?)?.isNotEmpty == true
              ? map['imagen'] as String
              : null;

      final double rawLatitude =
          _toDouble(map['latitude'] ?? map['latitud']);
      final double rawLongitude =
          _toDouble(map['longitude'] ?? map['longitud']);

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

  
  //  HORARIO DE CAFETERÍA
  
  Future<CafeteriaSchedule?> getCafeteriaHorario(String cafeteriaId) async {
   
    final uri = Uri.parse('$baseUrl/horarios/horarios/$cafeteriaId');
    final resp = await _client.get(uri);

    print('GET $uri -> ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);

      if (data is Map<String, dynamic>) {
        return CafeteriaSchedule.fromJson(data);
      }

      
      if (data is List &&
          data.isNotEmpty &&
          data.first is Map<String, dynamic>) {
        return CafeteriaSchedule.fromJson(
            data.first as Map<String, dynamic>);
      }

      return null;
    }

    if (resp.statusCode == 404) {
      // Sin horario registrado para esa cafetería
      return null;
    }

    throw Exception('Failed to load horario (${resp.statusCode})');
  }

  Future<List<dynamic>> getCafeteriaCalificaciones(String cafeteriaId) async {
    final uri = Uri.parse('$baseUrl/calificaciones/$cafeteriaId');
    final resp = await _client.get(uri);
    print('GET $uri -> ${resp.statusCode}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to load calificaciones (${resp.statusCode})');
    }
    return json.decode(resp.body) as List<dynamic>;
  }

  Future<List<String>> getFavoritos(int userId) async {
    final uri = Uri.parse('$baseUrl/favoritos/$userId');
    final resp = await _client.get(uri);

    print('GET $uri -> ${resp.statusCode}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load favoritos (${resp.statusCode})');
    }

    final decoded = json.decode(resp.body);

    if (decoded is! List) {
      throw Exception(
        'Formato inesperado de favoritos: ${decoded.runtimeType}',
      );
    }

    return decoded.map<String>((dynamic item) {
      if (item is Map<String, dynamic>) {
        final cafeteriaId =
            item['cafeteria_id'] ?? item['cafeteria'] ?? item['id'];
        return cafeteriaId.toString();
      }
      return item.toString();
    }).toList();
  }

  Future<void> addFavorito({
    required int userId,
    required String cafeteriaId,
  }) async {
    final intCafeId = int.tryParse(cafeteriaId);
    if (intCafeId == null) {
      throw Exception('cafeteriaId no es un entero válido: $cafeteriaId');
    }

    final uri = Uri.parse('$baseUrl/favoritos/').replace(
      queryParameters: {
        'usuario_id': userId.toString(),
        'cafeteria_id': intCafeId.toString(),
      },
    );

    final resp = await _client.post(
      uri,
      headers: {'accept': 'application/json'},
    );

    print('POST $uri -> ${resp.statusCode}  ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to add favorito (${resp.statusCode})');
    }
  }

  Future<void> removeFavorito({
    required int userId,
    required String cafeteriaId,
  }) async {
    final intCafeId = int.tryParse(cafeteriaId);
    if (intCafeId == null) {
      throw Exception('cafeteriaId no es un entero válido: $cafeteriaId');
    }

    final uri = Uri.parse('$baseUrl/favoritos/').replace(
      queryParameters: {
        'usuario_id': userId.toString(),
        'cafeteria_id': intCafeId.toString(),
      },
    );

    final resp = await _client.delete(
      uri,
      headers: {'accept': 'application/json'},
    );

    print('DELETE $uri -> ${resp.statusCode}  ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to remove favorito (${resp.statusCode})');
    }
  }
}
