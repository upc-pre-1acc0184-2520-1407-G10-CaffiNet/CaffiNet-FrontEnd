import 'package:caffinet_app_flutter/features/guide/domain/entities/cafeteria.dart';
import 'package:caffinet_app_flutter/features/guide/domain/repositories/guide_repository.dart';
import 'package:latlong2/latlong.dart';
import '../datasources/guide_remote_datasource.dart';

class GuideRepositoryImpl implements GuideRepository {
  final GuideRemoteDataSource remoteDataSource;

  GuideRepositoryImpl({required this.remoteDataSource});

  // Llama al DataSource y mapea el Modelo a la Entidad
  @override
  Future<Cafeteria> getCafeteriaDetail(String cafeteriaId) async {
    try {
      final cafeteriaModel = await remoteDataSource.getCafeteriaDetail(cafeteriaId);
      // Convierte el modelo de datos a la entidad pura
      return cafeteriaModel.toEntity();
    } catch (e) {
      // Manejo de errores o re-lanzamiento de una excepción de Dominio
      rethrow; 
    }
  }

  // Llama al DataSource para obtener la ubicación del usuario
  @override
  Future<LatLng> getUserLocation() async {
    try {
      return await remoteDataSource.getCurrentUserLocation();
    } catch (e) {
      rethrow;
    }
  }
}