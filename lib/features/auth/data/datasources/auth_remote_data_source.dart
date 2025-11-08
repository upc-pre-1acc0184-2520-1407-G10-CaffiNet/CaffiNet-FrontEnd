import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(String name, String email, String password);
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> register(
      String name, String email, String password) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
    };
    final response = await client.post(ApiConstants.registerEndpoint, body: body);
    // Asumiendo que el backend devuelve un mapa de usuario al registrar
    return UserModel.fromJson(response); 
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };
    final response = await client.post(ApiConstants.loginEndpoint, body: body);
    // Asumiendo que el backend devuelve un mapa de usuario al iniciar sesión
    return UserModel.fromJson(response);
  }
}