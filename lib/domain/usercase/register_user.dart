import 'package:caffinet_app_flutter/domain/model/user.dart';
import 'package:caffinet_app_flutter/data/repository/user_repository_impl.dart';


class RegisterUserUseCase {
  final UserRepositoryImpl repository;

  RegisterUserUseCase(this.repository);

  Future<User> execute(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }
    return await repository.register(name, email, password);
  }
}