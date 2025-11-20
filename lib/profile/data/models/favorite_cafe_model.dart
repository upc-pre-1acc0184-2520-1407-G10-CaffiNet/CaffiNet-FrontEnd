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
    return FavoriteCafeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ??
          json['name']?.toString() ??
          'Cafetería',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      distancia: json['distancia'] != null
          ? double.tryParse(json['distancia'].toString())
          : null,
      categoria: json['categoria']?.toString(),
      nivel: json['nivel']?.toString(), 
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
