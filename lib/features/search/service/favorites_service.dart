import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoritesService {
  final String baseUrl;

  FavoritesService({required this.baseUrl});

  
  Future<List<int>> getFavorites(int userId) async {
    final url = Uri.parse('$baseUrl/favoritos/$userId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener favoritos');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

   
    return data
        .map((e) => e['cafeteria_id'] as int)
        .toList();
  }

 
  Future<void> addFavorite({
    required int userId,
    required int cafeteriaId,
  }) async {
    final url = Uri.parse('$baseUrl/favoritos/');
    final body = jsonEncode({
      'usuario_id': userId,
      'cafeteria_id': cafeteriaId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar favorito');
    }
  }

  
  Future<void> removeFavorite({
    required int userId,
    required int cafeteriaId,
  }) async {
    final url = Uri.parse('$baseUrl/favoritos/');
    final body = jsonEncode({
      'usuario_id': userId,
      'cafeteria_id': cafeteriaId,
    });

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar favorito');
    }
  }
}
