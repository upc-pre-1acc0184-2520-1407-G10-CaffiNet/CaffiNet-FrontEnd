import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../models/home_ui_models.dart';

class HomePageViewModel extends ChangeNotifier {
  HomePageViewModel({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _client.close();
    super.dispose();
  }

  bool isLoading = false;
  String? errorMessage;

  int selectedTagIndex = -1;

  final List<PopularTag> popularTags = const [
    PopularTag(
      icon: Icons.pets,
      name: 'Pet Friendly',
      filterKey: 'pet_friendly',
    ),
    PopularTag(
      icon: Icons.wifi,
      name: 'Free Wi-Fi',
      filterKey: 'wifi',
    ),
    PopularTag(
      icon: Icons.volume_off,
      name: 'Peaceful',
      filterKey: 'peaceful',
    ),
    PopularTag(
      icon: Icons.more_horiz,
      name: 'More',
      filterKey: 'more',
    ),
  ];

  /// 3 cafeterías para "Suggested for You"
  List<HomeCafeItem> suggestedItems = [];

  /// cafetería más cercana
  HomeCafeItem? nearestItem;

  /// ubicación actual del usuario (para el mapa de Nearby)
  LatLng? userLatLng;

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      await _loadData();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> _loadData() async {
    // 1) Ubicación actual
    final pos = await _getCurrentPosition();
    userLatLng = LatLng(pos.latitude, pos.longitude);

    // 2) Traer todas las cafeterías (sin rating todavía)
    var allCafes = await _fetchCafeterias(userLatLng!);

    // 3) Ordenar por distancia (de más cerca a más lejos)
    allCafes.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    // 4) Calcular rating SOLO para las 10 más cercanas, en paralelo
    allCafes = await _attachRatingsToNearest(allCafes, maxCafes: 10);

    // 5) La más cercana para "Nearby Coffe Shopp"
    if (allCafes.isNotEmpty) {
      nearestItem = allCafes.first;
    }

    // 6) Suggested for You: 3 aleatorias entre las 10 más cercanas
    final candidates = allCafes.take(10).toList();
    candidates.shuffle();
    final count = candidates.length < 3 ? candidates.length : 3;
    suggestedItems = candidates.take(count).toList();

    if (!_isDisposed) notifyListeners();
  }

  void retry() => init();

  void selectTag(int index) {
    selectedTagIndex = index;
    if (!_isDisposed) notifyListeners();
  }

  

  static const String _baseUrl =
      kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  
  Future<List<HomeCafeItem>> _fetchCafeterias(LatLng user) async {
    final uri = Uri.parse('$_baseUrl/cafeterias/cafeterias/');
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error al obtener cafeterías: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);

    final List<HomeCafeItem> result = [];

    for (final raw in data) {
      final map = raw as Map<String, dynamic>;

      // Coordenadas
      final lat = _decodeLat(map['latitude'] as num);
      final lng = _decodeLng(map['longitude'] as num);

      // Distancia user–café
      final distanceKm = _distanceInKm(
        user.latitude,
        user.longitude,
        lat,
        lng,
      );

      // Texto en millas
      final distanceLabel = _formatDistanceMiles(distanceKm);

      // Tags
      final tags = _buildTagsFromRaw(map);

      result.add(
        HomeCafeItem(
          id: map['cafeteria_id'] as int,
          name: map['name'] as String,
          lat: lat,
          lng: lng,
          distanceKm: distanceKm,
          distanceLabel: distanceLabel,
          rating: 0.0, // provisional
          reviews: 0,  // provisional
          level: 'Bronze', // provisional, se recalcula luego
          tags: tags,
        ),
      );
    }

    return result;
  }

 
  Future<List<HomeCafeItem>> _attachRatingsToNearest(
    List<HomeCafeItem> cafes, {
    int maxCafes = 10,
  }) async {
    if (cafes.isEmpty) return cafes;

    final subset = cafes.take(maxCafes).toList();

    
    final infos = await Future.wait(
      subset.map((c) => _fetchRatingInfo(c.id)),
    );

    final Map<int, _RatingInfo> idToInfo = {};
    for (var i = 0; i < subset.length; i++) {
      idToInfo[subset[i].id] = infos[i];
    }

    // Devolvemos una nueva lista 
    return cafes.map((c) {
      final info = idToInfo[c.id];
      if (info == null) return c;

      final level = _levelFromRating(info.average);

      return c.copyWith(
        rating: info.average,
        reviews: info.count,
        level: level,
      );
    }).toList();
  }

  /// Calcula promedio y cantidad de reseñas de una cafetería
  Future<_RatingInfo> _fetchRatingInfo(int cafeId) async {
    try {
      final uri = Uri.parse('$_baseUrl/calificaciones/$cafeId');
      final res = await _client.get(uri);

      if (res.statusCode != 200) {
        return const _RatingInfo(0.0, 0);
      }

      final data = jsonDecode(res.body);
      if (data is! List) {
        return const _RatingInfo(0.0, 0);
      }

      double sum = 0.0;
      int count = 0;

      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final raw = item['rating'];
        if (raw == null) continue;

        double value;
        if (raw is num) {
          value = raw.toDouble();
        } else {
          value = double.tryParse(raw.toString()) ?? 0.0;
        }

        sum += value;
        count++;
      }

      if (count == 0) {
        return const _RatingInfo(0.0, 0);
      }

      return _RatingInfo(sum / count, count);
    } catch (_) {
      return const _RatingInfo(0.0, 0);
    }
  }

  static String _levelFromRating(double rating) {
    if (rating < 3.5) return 'Bronze';
    if (rating < 4.3) return 'Silver';
    return 'Gold';
  }

  static List<String> _buildTagsFromRaw(Map<String, dynamic> raw) {
    final tags = <String>[];

   
    final dynamic rawTags = raw['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String && t.trim().isNotEmpty) {
          tags.add(t.trim());
        }
      }
    }

   
    if (tags.isEmpty) {
      final petFriendly = (raw['pet_friendly'] as bool?) ?? false;
      final wifi = (raw['wifi'] as bool?) ?? false;
      final terraza = (raw['terraza'] as bool?) ?? false;
      final enchufes = (raw['enchufes'] as bool?) ?? false;
      final String? tipoMusica = raw['tipo_musica'] as String?;
      final String? estiloDecorativo = raw['estilo_decorativo'] as String?;

      if (petFriendly) tags.add('Pet-friendly');
      if (wifi) tags.add('Free Wi-Fi');
      if (terraza) tags.add('Terraza');
      if (enchufes) tags.add('Power Outlets');
      if (tipoMusica != null && tipoMusica.trim().isNotEmpty) {
        tags.add(tipoMusica.trim());
      }
      if (estiloDecorativo != null && estiloDecorativo.trim().isNotEmpty) {
        tags.add(estiloDecorativo.trim());
      }
    }

    return tags;
  }

  // UBICACIÓN 

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Activa el servicio de ubicación del dispositivo');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente. '
        'Ve a Ajustes > Aplicaciones > Permisos para activarlo.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  

  static double _decodeLat(num value) {
    final d = value.toDouble();

    if (d >= -90 && d <= 90) return d;

    final d6 = d / 1e6;
    if (d6 >= -90 && d6 <= 90) return d6;

    final d7 = d / 1e7;
    if (d7 >= -90 && d7 <= 90) return d7;

    final d8 = d / 1e8;
    if (d8 >= -90 && d8 <= 90) return d8;

    return d.clamp(-90.0, 90.0);
  }

  static double _decodeLng(num value) {
    final d = value.toDouble();

    if (d >= -180 && d <= 180) return d;

    final d6 = d / 1e6;
    if (d6 >= -180 && d6 <= 180) return d6;

    final d7 = d / 1e7;
    if (d7 >= -180 && d7 <= 180) return d7;

    final d8 = d / 1e8;
    if (d8 >= -180 && d8 <= 180) return d8;

    return d.clamp(-180.0, 180.0);
  }

  static double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;

  static String _formatDistanceMiles(double km) {
    final miles = km * 0.621371;
    return '${miles.toStringAsFixed(1)} mi';
  }
}


class _RatingInfo {
  final double average;
  final int count;

  const _RatingInfo(this.average, this.count);
}

