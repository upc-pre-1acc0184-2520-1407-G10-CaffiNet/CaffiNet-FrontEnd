import 'package:caffinet_app_flutter/core/di/injector.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_bloc.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_event.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/guide_header.dart';
import '../widgets/guide_map_widget.dart';

// 1. Convertimos a StatefulWidget para tener ciclo de vida
class GuidePage extends StatefulWidget {
  final String? cafeteriaId;
  final String? cafeteriaName;

  const GuidePage({
    this.cafeteriaId,
    this.cafeteriaName,
    super.key,
  });

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  // Guardamos la referencia del Bloc aquí
  late GuideBloc _guideBloc;

  @override
  void initState() {
    super.initState();
    // 2. Inicializamos el Bloc manualmente
    _guideBloc = sl<GuideBloc>();
    
    // Si hay ID al entrar, cargamos la data
    if (widget.cafeteriaId != null) {
      _guideBloc.add(GetGuideDataEvent(widget.cafeteriaId!));
    }
  }

  // 3. ESTA ES LA CLAVE: Detectamos cambios en los parámetros
  @override
  void didUpdateWidget(covariant GuidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si el ID cambió (por ejemplo, seleccionaste otra opción en el search)
    // y el nuevo ID no es nulo, disparamos el evento de nuevo.
    if (widget.cafeteriaId != oldWidget.cafeteriaId && widget.cafeteriaId != null) {
       _guideBloc.add(GetGuideDataEvent(widget.cafeteriaId!));
    }
  }

  @override
  void dispose() {
    // 4. Cerramos el Bloc manualmente al salir de la pantalla
    _guideBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Usamos BlocProvider.value porque nosotros creamos el Bloc en initState
    return BlocProvider.value(
      value: _guideBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guía de Navegación'),
        ),
        body: SafeArea(
          child: BlocBuilder<GuideBloc, GuideState>(
            builder: (context, state) {
              
              if (state is GuideInitial) {
                return const _PlaceholderView();
              }

              if (state is GuideLoading) {
                return Column(
                  children: [
                    GuideHeader(
                      cafeteriaName: widget.cafeteriaName ?? 'Cargando...',
                      userLocationName: 'Cargando ubicación...',
                    ),
                    const Expanded(child: Center(child: CircularProgressIndicator())),
                  ],
                );
              }

              if (state is GuideError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is GuideLoaded) {
                return Column(
                  children: [
                    GuideHeader(
                      cafeteriaName: state.cafeteria.name,
                      userLocationName: state.userLocationName,
                      onDismiss: () {
                        // Reseteamos el BLoC
                        _guideBloc.add(ResetGuideEvent());
                      },
                    ),
                    Expanded(
                      child: GuideMapWidget(
                        cafeteria: state.cafeteria,
                        userLocation: state.userLocation,
                      ),
                    ),
                  ],
                );
              }

              return const _PlaceholderView();
            },
          ),
        ),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          "Selecciona una cafetería para mostrar su guía :p",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}