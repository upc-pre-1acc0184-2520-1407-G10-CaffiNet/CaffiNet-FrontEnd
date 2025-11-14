enum OpenStatus { open, closed }
enum CafeTier { bronze, silver, gold }

class SearchResult {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int ratingCount;
  final double distanceMi;
  final List<String> tags;
  final OpenStatus status;
  final CafeTier tier;
  final String? thumbnail;

  // Nuevos flags para filtros
  final bool petFriendly;
  final bool hasWifi;
  final bool hasReservations;
  final bool hasParking;
  final bool hasMusic;

  // Coordenadas para el mapa
  final double latitude;
  final double longitude;

  const SearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.ratingCount,
    required this.distanceMi,
    required this.tags,
    required this.status,
    required this.tier,
    this.thumbnail,
    this.petFriendly = false,
    this.hasWifi = false,
    this.hasReservations = false,
    this.hasParking = false,
    this.hasMusic = false,
    required this.latitude,
    required this.longitude,
  });

  // Método copyWith para crear un nuevo objeto con cambios
  SearchResult copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    int? ratingCount,
    double? distanceMi,
    List<String>? tags,
    OpenStatus? status,
    CafeTier? tier,
    String? thumbnail,
    bool? petFriendly,
    bool? hasWifi,
    bool? hasReservations,
    bool? hasParking,
    bool? hasMusic,
    double? latitude,
    double? longitude,
  }) {
    return SearchResult(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      distanceMi: distanceMi ?? this.distanceMi,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      thumbnail: thumbnail ?? this.thumbnail,
      petFriendly: petFriendly ?? this.petFriendly,
      hasWifi: hasWifi ?? this.hasWifi,
      hasReservations: hasReservations ?? this.hasReservations,
      hasParking: hasParking ?? this.hasParking,
      hasMusic: hasMusic ?? this.hasMusic,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class SearchFilters {
  final String query;
  final Set<String> selectedTags;

  const SearchFilters({
    this.query = '',
    this.selectedTags = const {},
  });

  SearchFilters copyWith({String? query, Set<String>? selectedTags}) {
    return SearchFilters(
      query: query ?? this.query,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

enum SortBy { rating, distance, name }

extension CafeTierX on CafeTier {
  String get label => switch (this) {
        CafeTier.bronze => 'Bronze',
        CafeTier.silver => 'Silver',
        CafeTier.gold => 'Gold',
      };
}

/// Modelo para el horario de la cafetería (endpoint /horarios/{cafeteria_id})
class CafeteriaSchedule {
  final int cafeteriaId;
  final String horaApertura;
  final String horaCierre;
  final String diasAbre;

  const CafeteriaSchedule({
    required this.cafeteriaId,
    required this.horaApertura,
    required this.horaCierre,
    required this.diasAbre,
  });

  factory CafeteriaSchedule.fromJson(Map<String, dynamic> json) {
    return CafeteriaSchedule(
      cafeteriaId: json['cafeteria_id'] as int,
      horaApertura: json['hora_apertura'] as String,
      horaCierre: json['hora_cierre'] as String,
      diasAbre: json['dias_abre'] as String,
    );
  }
}
