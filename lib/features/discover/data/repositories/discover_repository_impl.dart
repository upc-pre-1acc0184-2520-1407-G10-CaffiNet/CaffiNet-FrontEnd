import 'package:caffinet_app_flutter/features/discover/domain/repositories/discover_repository.dart';
import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/route_preferences.dart';

import '../datasources/discover_remote_data_source.dart';
import '../models/route_preferences_model.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverRemoteDataSource remoteDataSource;

  DiscoverRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OptimalRouteResult> calculateOptimalRoute(RoutePreferences preferences) async {
    // 1. Mapea la entidad de dominio a un modelo de datos (para el Backend)
    final preferencesModel = RoutePreferencesModel(
      algorithm: preferences.algorithm,
      userLat: preferences.userLat,
      userLng: preferences.userLng,
      filters: preferences.filters,
    );

    // 2. Llama a la fuente de datos remota
    final resultModel = await remoteDataSource.calculateOptimalRoute(preferencesModel);

    // 3. El modelo que recibimos ya extiende la entidad de dominio, 
    //    por lo que se puede retornar directamente (o mapear si no extendiera).
    return resultModel;
  }
}