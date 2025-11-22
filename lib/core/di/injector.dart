// lib/injection_container.dart

import 'package:caffinet_app_flutter/core/api/api_client.dart';
import 'package:caffinet_app_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:caffinet_app_flutter/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';
import 'package:caffinet_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/register_user.dart';
import 'package:caffinet_app_flutter/features/guide/data/datasources/guide_remote_datasource.dart';
import 'package:caffinet_app_flutter/features/guide/data/repositories/guide_repository_impl.dart';
import 'package:caffinet_app_flutter/features/guide/domain/repositories/guide_repository.dart';
import 'package:caffinet_app_flutter/features/guide/domain/usecases/get_guide_data.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;


final GetIt sl = GetIt.instance;

void init() {
  // -------------------------
  // 1. Feature: Auth (Registro, Login)
  // -------------------------

  // Use cases (Dominio)
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));

  // Repositorios (Dominio e Implementación de Datos)
  // Asumiendo que UserRepositoryImpl implementa AuthRepository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Sources (Datos)
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl<ApiClient>()));

  // ----------------------------------------------------
  // 2. Feature: Guide (Mapa y Ubicación) <--- NUEVA SECCIÓN
  // ----------------------------------------------------

  // Presentation - BLoC
  sl.registerFactory(() => GuideBloc(
        getGuideData: sl(),
      ));

  // Domain - Usecases
  sl.registerLazySingleton(() => GetGuideData(
        sl(), // Inyecta GuideRepository
      ));

  // Domain - Repository (Contrato)
  sl.registerLazySingleton<GuideRepository>(() => GuideRepositoryImpl(
        remoteDataSource: sl(), // Inyecta GuideRemoteDataSource
      ));

  // Data - DataSources
  // Usamos el ApiClient registrado para el RemoteDataSource
  sl.registerLazySingleton<GuideRemoteDataSource>(() => GuideRemoteDataSourceImpl(
        client: sl<ApiClient>(),
      ));

  // -------------------------
  // 3. Core & Externos
  // -------------------------
  
  // Cliente HTTP base (usado por ApiClient)
  sl.registerLazySingleton(() => http.Client());

  // Tu ApiClient (usa el http.Client)
  sl.registerLazySingleton(() => ApiClient(client: sl()));
}