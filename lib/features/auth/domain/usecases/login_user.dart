import 'package:caffinet_app_flutter/features/auth/domain/usecases/usecase.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Clase que encapsula la lógica para iniciar sesión.
/// Recibe el email y la password, y devuelve la entidad User.
class LoginUserUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  // El UseCase solo conoce la abstracción (AuthRepository)
  LoginUserUseCase(this.repository);

  // Implementa el método execute de la clase base UseCase
  @override
  Future<User> execute(LoginParams params) async {
    return await repository.loginUser(
      params.email,
      params.password,
    );
  }
}

/// Parámetros necesarios para el LoginUserUseCase.
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}