import 'package:caffinet_app_flutter/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../api/api_client.dart'; 
// Asumo que user_repository_impl.dart es AuthRepositoryImpl
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart'; 

final GetIt sl = GetIt.instance;

void init() {
  // -------------------------
  // 1. Feature: Auth (Registro, Login)
  // -------------------------

  // Use cases (Dominio)
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));

  // Repositorios (Dominio e Implementación de Datos)
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Sources (Datos)
  // CORRECCIÓN CLAVE: Inyecta ApiClient en lugar del cliente http básico.
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl<ApiClient>()));

  // -------------------------
  // 2. Core & Externos
  // -------------------------
  
  // Cliente HTTP base (usado por ApiClient)
  sl.registerLazySingleton(() => http.Client());

  // Tu ApiClient (usa el http.Client)
  sl.registerLazySingleton(() => ApiClient(client: sl()));
}