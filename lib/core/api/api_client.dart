// lib/core/api/api_client.dart
import 'dart:convert';
import 'package:caffinet_app_flutter/core/errors/exceptions.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

// Clase base para excepciones de API, si no existe
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
class HttpException implements Exception {
  final int statusCode;
  final String message;
  HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $statusCode - $message';
}


class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Future<Map<String, dynamic>> post(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Agrega aquí el header de autorización si es necesario
    };

    try {
      final response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Asume que la respuesta exitosa devuelve un JSON
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw AuthException('Credenciales inválidas');
      } else {
        // Manejo de errores genéricos o errores de validación del backend
        final errorBody = jsonDecode(response.body);
        throw HttpException(response.statusCode, errorBody['message'] ?? 'Error desconocido');
      }
    } on Exception catch (e) {
      // Re-lanza para que las capas superiores puedan manejarlo
      throw ServerException('Error de conexión o servidor: ${e.toString()}');
    }
  }

  // Puedes añadir métodos para GET, PUT, DELETE, etc.
}