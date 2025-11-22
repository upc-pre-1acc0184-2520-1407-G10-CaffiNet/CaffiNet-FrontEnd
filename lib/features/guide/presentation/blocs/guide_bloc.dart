// guide/presentation/blocs/guide_bloc.dart

import 'package:caffinet_app_flutter/features/guide/domain/usecases/get_guide_data.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'guide_event.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final GetGuideData getGuideData;

  GuideBloc({required this.getGuideData}) : super(GuideInitial()) {
    on<GetGuideDataEvent>(_onGetGuideData);
  }

  void _onGetGuideData(
    GetGuideDataEvent event,
    Emitter<GuideState> emit,
  ) async {
    emit(GuideLoading());

    try {
      // 1. Llamar al Caso de Uso inyectado
      final guideData = await getGuideData.call(event.cafeteriaId);

      // 2. Emitir el estado de éxito con los datos combinados
      emit(GuideLoaded(
        cafeteria: guideData.cafeteria,
        userLocation: guideData.userLocation,
        userLocationName: guideData.userLocationName,
      ));
    } catch (e) {
      // 3. Manejo de errores
      print(e); // En un caso real, usar un logger
      emit(const GuideError('No se pudo cargar la información de la guía. Verifica la conexión y los permisos de ubicación.'));
    }
  }
}