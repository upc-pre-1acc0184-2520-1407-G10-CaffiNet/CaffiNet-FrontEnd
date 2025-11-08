import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  Future<User> execute(String email, String password) async {
    return await repository.loginUser(email, password);
  }
}