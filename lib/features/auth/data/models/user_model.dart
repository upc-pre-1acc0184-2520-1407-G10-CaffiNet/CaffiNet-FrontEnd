
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name; 
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // Constructor general (asume que el backend devuelve todo, usado en Login)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Esto podría fallar si 'nombre' no viene.
    return UserModel(
      id: json['id'] != null ? json['id'].toString() : '0', 
      name: (json['nombre'] as String?) ?? '', // Hacemos 'nombre' opcional
      email: json['email'] as String,
    );
  }
  
  // 🚨 CONSTRUCTOR ESPECÍFICO PARA REGISTRO
  // Usa la respuesta parcial del backend (solo ID y Email) y el nombre que enviamos.
  factory UserModel.fromRegistrationResponse({
    required Map<String, dynamic> json,
    required String suppliedName,
  }) {
    final idString = json['id'] != null ? json['id'].toString() : '0';
    final emailString = (json['email'] as String?) ?? '';

    return UserModel(
      id: idString,
      name: suppliedName, // <--- Usamos el nombre que ENVIAMOS
      email: emailString,
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