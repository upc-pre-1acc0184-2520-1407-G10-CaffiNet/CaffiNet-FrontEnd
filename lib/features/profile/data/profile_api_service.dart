import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/user_model.dart';
import 'models/favorite_cafe_model.dart';

class ProfileApiService {
  final String baseUrl;

  ProfileApiService({
    this.baseUrl = 'http://127.0.0.1:8000', 
  });

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<UserModel> getUser(int userId) async {
    final resp = await http.get(_uri('/usuarios/$userId'));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Error al obtener usuario: ${resp.statusCode}');
    }
  }

  Future<UserModel> updateUser({
    required int userId,
    required String nombre,
    required String email,
    required String password,
  }) async {
    final resp = await http.put(
      _uri('/usuarios/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Error al actualizar usuario: ${resp.statusCode}');
    }
  }


  Future<List<FavoriteCafeModel>> getFavoritos(int userId) async {
    
    final resp = await http.get(_uri('/favoritos/$userId'));

    if (resp.statusCode != 200) {
      throw Exception('Error al obtener favoritos: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body);
    final List<dynamic> rawList = data is List ? data : [];

    final List<FavoriteCafeModel> favoritos = [];

    
    for (final fav in rawList) {
      if (fav is! Map<String, dynamic>) continue;

      final dynamic rawCafeId = fav['cafeteria_id'] ?? fav['id_cafeteria'];
      if (rawCafeId == null) continue;

      final int cafeId = rawCafeId is int
          ? rawCafeId
          : int.tryParse(rawCafeId.toString()) ?? 0;

      if (cafeId == 0) continue;

      
      final cafeResp =
          await http.get(_uri('/cafeterias/cafeterias/$cafeId'));

      if (cafeResp.statusCode != 200) {
        
        continue;
      }

      final cafeJson = jsonDecode(cafeResp.body);
      if (cafeJson is Map<String, dynamic>) {
        favoritos.add(FavoriteCafeModel.fromJson(cafeJson));
      }
    }

    return favoritos;
  }
}
