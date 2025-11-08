// lib/features/auth/data/datasources/auth_remote_data_source.dart

import '../../data/models/user_model.dart';

/// Define el contrato (interfaz) para interactuar con los servicios de autenticación remotos (APIs).
abstract class AuthRemoteDataSource {
  /// Llama al endpoint de registro y devuelve el modelo de datos.
  Future<UserModel> register(String name, String email, String password);

  /// Llama al endpoint de inicio de sesión y devuelve el modelo de datos.
  Future<UserModel> login(String email, String password);
}