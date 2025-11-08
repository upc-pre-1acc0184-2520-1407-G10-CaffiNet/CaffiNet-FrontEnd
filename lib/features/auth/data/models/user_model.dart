// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user.dart';

/// Modelo de datos que maneja la serialización y deserialización
/// de los datos del usuario entre el backend y la aplicación.
class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Factory constructor para crear un UserModel a partir de un mapa JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Asegúrate de que las claves ('id', 'name', 'email') 
    // coincidan exactamente con la respuesta JSON de tu backend.
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  /// Convierte el Modelo de Datos a la Entidad de Dominio.
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
    );
  }
}