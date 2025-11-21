// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> registerUser(String name, String email, String password);
  Future<User> loginUser(String email, String password);
}