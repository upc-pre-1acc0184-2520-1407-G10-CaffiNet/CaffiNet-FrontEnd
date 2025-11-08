// lib/features/auth/domain/usecases/register_user.dart (Modificación)
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// Asumo que tienes una clase UseCase base. Si no, omítela.
// abstract class UseCase<Type, Params> { Future<Type> call(Params params); }

class RegisterUserUseCase { // Ya no extiende UseCase
  final AuthRepository repository; // Recibe la interfaz

  RegisterUserUseCase(this.repository);

  // El método 'execute' es tu implementación de 'call'
  Future<User> execute(String name, String email, String password) async {
    // La lógica de negocio mínima si fuera necesaria
    return await repository.registerUser(name, email, password);
  }
}