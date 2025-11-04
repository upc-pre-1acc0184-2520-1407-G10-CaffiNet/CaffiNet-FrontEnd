import 'package:caffinet_app_flutter/features/auth/data/models/user_model.dart';
import 'package:caffinet_app_flutter/core/api/api_service.dart';
import 'package:caffinet_app_flutter/features/auth/domain/entities/user.dart';

class UserRepositoryImpl {
  final ApiService apiService;

  UserRepositoryImpl(this.apiService);

  Future<User> login(String email, String password) async {
    final json = await apiService.login(email, password);
    return UserModel.fromJson(json);
  }

  Future<User> register(String name, String email, String password) async {
    final json = await apiService.register(name, email, password);
    return UserModel.fromJson(json);
  }
}