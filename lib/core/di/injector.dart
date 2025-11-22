import 'package:caffinet_app_flutter/core/api/api_client.dart';
import 'package:caffinet_app_flutter/core/service/osrm_service.dart';
// Auth
import 'package:caffinet_app_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:caffinet_app_flutter/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';
import 'package:caffinet_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/register_user.dart';
// Guide
import 'package:caffinet_app_flutter/features/guide/data/datasources/guide_remote_datasource.dart';
import 'package:caffinet_app_flutter/features/guide/data/repositories/guide_repository_impl.dart';
import 'package:caffinet_app_flutter/features/guide/domain/repositories/guide_repository.dart';
import 'package:caffinet_app_flutter/features/guide/domain/usecases/get_guide_data.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_bloc.dart';
// Discover
import 'package:caffinet_app_flutter/features/discover/data/datasources/discover_remote_data_source.dart';
import 'package:caffinet_app_flutter/features/discover/data/repositories/discover_repository_impl.dart';
import 'package:caffinet_app_flutter/features/discover/domain/repositories/discover_repository.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/get_optimal_route_usecase.dart';
import 'package:caffinet_app_flutter/features/discover/presentation/blocs/discover_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;


final GetIt sl = GetIt.instance; // sl = service locator

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
    sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(client: sl<ApiClient>()));

    // ----------------------------------------------------
    // 2. Feature: Guide (Mapa y Ubicación)
    // ----------------------------------------------------

    // Presentation - BLoC
    sl.registerFactory(() => GuideBloc(
        getGuideData: sl(), 
    ));

    // Domain - Usecases
    sl.registerLazySingleton(() => GetGuideData(
        sl(), 
    ));

    // Domain - Repository (Contrato)
    sl.registerLazySingleton<GuideRepository>(() => GuideRepositoryImpl(
        remoteDataSource: sl(), 
    ));

    // Data - DataSources
    sl.registerLazySingleton<GuideRemoteDataSource>(() => GuideRemoteDataSourceImpl(
        client: sl<ApiClient>(),
    ));

    // ====================================================
    // 3. Feature: Discover (Algoritmos de Ruta Óptima) 🚀
    // ====================================================

    // Presentation - BLoC
    // Registrado como Factory porque cada instancia de DiscoverPage necesitará su propio BLoC
    sl.registerFactory(() => DiscoverBloc(
      getOptimalRoute: sl(), // Inyecta GetOptimalRouteUseCase
      osrmService: sl(), // 🛑 INYECTA EL SERVICIO OSRM
    ));

    // Domain - Usecases
    // Singleton, ya que la lógica de negocio debe ser única
    sl.registerLazySingleton(() => GetOptimalRouteUseCase(
        sl(), // Inyecta DiscoverRepository
    ));

    // Domain - Repository (Contrato)
    sl.registerLazySingleton<DiscoverRepository>(() => DiscoverRepositoryImpl(
        remoteDataSource: sl(), // Inyecta DiscoverRemoteDataSource
    ));

    // Data - DataSources
    // Asumiendo que DiscoverRemoteDataSourceImpl usa ApiClient (o http.Client)
    sl.registerLazySingleton<DiscoverRemoteDataSource>(() => DiscoverRemoteDataSourceImpl(
        client: sl<http.Client>(), // Usa el ApiClient registrado
    ));

    // -------------------------
    // 4. Core & Externos
    // -------------------------
    
    // Cliente HTTP base (usado por ApiClient)
    sl.registerLazySingleton(() => http.Client());

    // Tu ApiClient (usa el http.Client)
    // ApiClient actúa como un wrapper o punto central para configuraciones de headers/intercepción
    sl.registerLazySingleton(() => ApiClient(client: sl()));

    sl.registerLazySingleton(() => OSRMService(client: sl())); // Usa el http.Client


}