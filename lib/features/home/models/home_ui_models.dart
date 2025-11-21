// lib/features/home/models/home_ui_models.dart
import 'package:flutter/material.dart';

/// Tag que se muestra en "Popular Tags"
class PopularTag {
  final IconData icon;
  final String name;
  final String filterKey; // clave para filtrar en search/backend

  const PopularTag({
    required this.icon,
    required this.name,
    required this.filterKey,
  });
}

/// Item que se usa en Suggested for You, Nearby, etc.
class HomeCafeItem {
  final int id;
  final String name;

  /// Coordenadas de la cafetería
  final double lat;
  final double lng;

  /// Distancia en km (para lógica interna)
  final double distanceKm;

  /// Texto ya formateado para la UI (ej. "1.8 mi")
  final String distanceLabel;

  /// Rating y nº de reseñas
  final double rating;
  final int reviews;

  /// Bronze / Silver / Gold
  final String level;

  /// Tags: "Free Wi-Fi", "Pet Friendly", etc.
  final List<String> tags;

  /// URL opcional de imagen (para listas pequeñas, etc.)
  final String? imageUrl;

  const HomeCafeItem({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.distanceLabel,
    required this.rating,
    required this.reviews,
    required this.level,
    required this.tags,
    this.imageUrl,
  });
}
