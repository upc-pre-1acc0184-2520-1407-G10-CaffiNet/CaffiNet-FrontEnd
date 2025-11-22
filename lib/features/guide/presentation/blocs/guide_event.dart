// guide/presentation/blocs/guide_event.dart

import 'package:equatable/equatable.dart';

abstract class GuideEvent extends Equatable {
  const GuideEvent();

  @override
  List<Object> get props => [];
}

// Evento que se dispara al entrar a la pantalla GuidePage,
// llevando consigo el ID de la cafetería seleccionada.
class GetGuideDataEvent extends GuideEvent {
  final String cafeteriaId;

  const GetGuideDataEvent(this.cafeteriaId);

  @override
  List<Object> get props => [cafeteriaId];
}