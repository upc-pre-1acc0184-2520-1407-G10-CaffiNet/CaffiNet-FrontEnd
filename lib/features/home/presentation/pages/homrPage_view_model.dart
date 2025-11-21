// lib/features/home/presentation/pages/homrPage_view_model.dart
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

  // ---------- estado ----------
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

  // ---------- ciclo de vida ----------
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _loadData();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    // 1) Ubicación actual
    final pos = await _getCurrentPosition();
    userLatLng = LatLng(pos.latitude, pos.longitude);

    // 2) Traer todas las cafeterías + calcular distancia real user–café
    final allCafes = await _fetchCafeterias(userLatLng!);

    // 3) Ordenar por distancia (de más cerca a más lejos)
    allCafes.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    // 4) La más cercana para la sección "Nearby"
    if (allCafes.isNotEmpty) {
      nearestItem = allCafes.first;
    }

    // 5) Suggested for You:
    //    3 cafeterías ALEATORIAS entre las 10 más cercanas
    final candidates = allCafes.take(10).toList(); // hasta 10 más cercanas
    candidates.shuffle();

    final count = candidates.length < 3 ? candidates.length : 3;
    suggestedItems = candidates.take(count).toList();
  }

  void retry() => init();

  void selectTag(int index) {
    selectedTagIndex = index;
    notifyListeners();
  }

  // ---------- red / backend ----------
  // Web => 127.0.0.1, Emulador => 10.0.2.2
  static const String _baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';

  Future<List<HomeCafeItem>> _fetchCafeterias(LatLng user) async {
    final uri = Uri.parse('$_baseUrl/cafeterias/cafeterias/');
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error al obtener cafeterías: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);

    final List<HomeCafeItem> result = [];
    int i = 0;

    for (final raw in data) {
      final map = raw as Map<String, dynamic>;

      // Coordenadas vienen “raras”; las normalizamos a grados decimales.
      final lat = _decodeLat(map['latitude'] as num);
      final lng = _decodeLng(map['longitude'] as num);

      // Distancia REAL user–café (en km)
      final distanceKm = _distanceInKm(
        user.latitude,
        user.longitude,
        lat,
        lng,
      );

      // Texto en millas para la UI
      final distanceLabel = _formatDistanceMiles(distanceKm);

      // Rating / reviews de relleno por ahora
      final rating =
          (map['rating'] as num?)?.toDouble() ?? (3.5 + (i % 3) * 0.5);
      final reviews = map['reviews'] as int? ?? (80 + i * 5);

      final level = rating < 3.5
          ? 'Bronze'
          : rating < 4.3
              ? 'Silver'
              : 'Gold';

      // 👇 AQUÍ construimos los tags reales
      final tags = _buildTagsFromRaw(map);

      result.add(
        HomeCafeItem(
          id: map['cafeteria_id'] as int,
          name: map['name'] as String,
          lat: lat,
          lng: lng,
          distanceKm: distanceKm,
          distanceLabel: distanceLabel,
          rating: rating,
          reviews: reviews,
          level: level,
          tags: tags,
        ),
      );

      i++;
    }

    return result;
  }

  /// Lee los tags reales del GET si existe `tags: [...]`.
  /// Si no, arma algunos a partir de los flags de la cafetería.
  static List<String> _buildTagsFromRaw(Map<String, dynamic> raw) {
    final tags = <String>[];

    // 1) Si el backend ya manda un arreglo "tags", lo usamos directo.
    final dynamic rawTags = raw['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String && t.trim().isNotEmpty) {
          tags.add(t.trim());
        }
      }
    }

    // 2) Si no hay "tags" o vino vacío, construimos algunos básicos
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

  // ---------- geolocalización ----------
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

  // ---------- helpers de coordenadas ----------
  /// Normaliza cualquier valor a un rango válido de latitud (-90, 90)
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

  /// Normaliza cualquier valor a un rango válido de longitud (-180, 180)
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

  // ---------- helpers de distancia ----------
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
