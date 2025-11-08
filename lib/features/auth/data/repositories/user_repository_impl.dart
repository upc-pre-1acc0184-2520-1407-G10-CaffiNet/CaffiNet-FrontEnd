// lib/features/auth/data/repositories/auth_repository_impl.dart

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> registerUser(String name, String email, String password) async {
    try {
      final userModel = await remoteDataSource.register(name, email, password);
      // Mapea de UserModel (sin token) a la entidad User (sin token)
      return userModel.toEntity();
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<User> loginUser(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      // Mapea de UserModel (sin token) a la entidad User (sin token)
      return userModel.toEntity();
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    }
  }
}