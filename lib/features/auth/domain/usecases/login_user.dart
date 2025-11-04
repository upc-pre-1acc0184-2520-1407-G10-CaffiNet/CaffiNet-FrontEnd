
import 'package:caffinet_app_flutter/features/auth/domain/entities/user.dart';
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';

class LoginUserUseCase {
  final UserRepositoryImpl  repository;

  LoginUserUseCase(this.repository);

  Future<User> execute(String email, String password) async {
    // Aquí podrías aplicar validaciones del dominio si quisieras
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    return await repository.login(email, password);
  }
}