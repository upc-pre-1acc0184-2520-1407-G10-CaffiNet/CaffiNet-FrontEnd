import 'package:caffinet_app_flutter/features/auth/domain/usecases/usecase.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Clase que encapsula la lógica para registrar un nuevo usuario.
/// Recibe name, email y password, y devuelve la entidad User.
class RegisterUserUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  // El UseCase solo conoce la abstracción (AuthRepository)
  RegisterUserUseCase(this.repository);

  // Implementa el método execute de la clase base UseCase
  @override
  Future<User> execute(RegisterParams params) async {
    return await repository.registerUser(
      params.name,
      params.email,
      params.password,
    );
  }
}

/// Parámetros necesarios para el RegisterUserUseCase.
class RegisterParams {
  final String name;
  final String email;
  final String password;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
}