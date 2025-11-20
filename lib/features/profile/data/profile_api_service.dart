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

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);

      final List<dynamic> rawList = data is List ? data : [];
      return rawList
          .map((e) => FavoriteCafeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener favoritos: ${resp.statusCode}');
    }
  }
}
