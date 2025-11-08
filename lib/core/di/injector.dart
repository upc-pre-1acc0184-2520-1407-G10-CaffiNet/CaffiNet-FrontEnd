// lib/core/di/injector.dart
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../api/api_client.dart';

final GetIt sl = GetIt.instance; // 'sl' es una convención común para Service Locator

void init() {
  // Use cases (Dominio)
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));

  // Repositorios (Dominio e Implementación de Datos)
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Sources (Datos)
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl()));

  // Core & Externos
  sl.registerLazySingleton(() => ApiClient(client: sl()));
  sl.registerLazySingleton(() => http.Client());
  
  // Puedes registrar los ViewModels aquí si quieres, pero con Provider se hace en la UI
}