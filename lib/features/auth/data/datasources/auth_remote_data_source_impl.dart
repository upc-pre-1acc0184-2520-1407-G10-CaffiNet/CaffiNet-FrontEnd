import '../../../../core/constants/api_constants.dart';
import '../../../../core/api/api_client.dart'; // Tu ApiClient

import '../../data/models/user_model.dart';
import 'auth_remote_data_source.dart';

/// Implementación concreta que utiliza el ApiClient para interactuar con la API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // CORRECCIÓN: Ahora la dependencia es tu ApiClient
  final ApiClient client; 

  AuthRemoteDataSourceImpl({required this.client});

@override
  // Recibimos el nombre para ENVIARLO, pero también lo usamos para la RESPUESTA
  Future<UserModel> register(String name, String email, String password) async {
    final responseJson = await client.post(
      ApiConstants.registerEndpoint,
      // 1. ENVÍO: Enviamos 'nombre', 'email', 'password' (CORRECTO)
      body: {
        'nombre': name, 
        'email': email,
        'password': password,
      },
    );
    
    // 2. RECEPCIÓN: Usamos el método que acepta una respuesta parcial y el nombre completo
    return UserModel.fromRegistrationResponse(
      json: responseJson,
      suppliedName: name, // Pasamos el nombre que acabamos de usar
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    // Usamos el método post de tu ApiClient
    final responseJson = await client.post(
      ApiConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    return UserModel.fromJson(responseJson);
  }
}