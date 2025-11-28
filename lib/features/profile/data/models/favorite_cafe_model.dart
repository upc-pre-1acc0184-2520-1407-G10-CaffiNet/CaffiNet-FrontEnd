class FavoriteCafeModel {
  final int id;
  final String nombre;
  final double? rating;
  final double? distancia;
  final String? categoria;
  final String? nivel;

  FavoriteCafeModel({
    required this.id,
    required this.nombre,
    this.rating,
    this.distancia,
    this.categoria,
    this.nivel,
  });

  factory FavoriteCafeModel.fromJson(Map<String, dynamic> json) {
    
    final dynamic rawId =
        json['cafeteria_id'] ?? json['id'] ?? json['id_cafeteria'];

    
    final String nombre = (json['name'] ??
            json['nombre'] ??
            json['nombre_cafeteria'] ??
            json['cafeteria_nombre'] ??
            'Cafetería')
        .toString();

    
    final dynamic rawRating =
        json['rating'] ?? json['calificacion_promedio'] ?? json['score'];
    final dynamic rawDist =
        json['distancia'] ?? json['distance'] ?? json['dist_mi'];

    return FavoriteCafeModel(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0,
      nombre: nombre,
      rating:
          rawRating != null ? double.tryParse(rawRating.toString()) : null,
      distancia:
          rawDist != null ? double.tryParse(rawDist.toString()) : null,
      
      categoria: json['categoria']?.toString() ??
          json['tag']?.toString() ??
          json['estilo_decorativo']?.toString(),
      nivel: json['nivel']?.toString() ?? json['tier']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'rating': rating,
      'distancia': distancia,
      'categoria': categoria,
      'nivel': nivel,
    };
  }
}
