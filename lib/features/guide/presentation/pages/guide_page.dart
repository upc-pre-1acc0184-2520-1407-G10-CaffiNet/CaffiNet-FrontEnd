import 'package:caffinet_app_flutter/core/di/injector.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_bloc.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_event.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/blocs/guide_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/guide_header.dart';
import '../widgets/guide_map_widget.dart';

class GuidePage extends StatelessWidget {
    // ⚠️ CAMBIO 1: Hacemos los parámetros ANULABLES (String?)
    final String? cafeteriaId; 
    final String? cafeteriaName; 

    const GuidePage({
        this.cafeteriaId, // Ya no son 'required'
        this.cafeteriaName, // Ya no son 'required'
        super.key,
    });

    @override
    Widget build(BuildContext context) {
        // ⚠️ CAMBIO 2: Lógica condicional para verificar si hay datos
        final bool isGuideReady = cafeteriaId != null && cafeteriaName != null;

        if (!isGuideReady) {
            // Si falta el ID o el Nombre, mostramos el mensaje de placeholder.
            return Scaffold(
                appBar: AppBar(
                    title: const Text('Guía de Navegación'),
                ),
                body: const Center(
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
                ),
            );
        }
        
        // Si hay datos (isGuideReady == true), continuamos con la lógica normal del BLoC
        // Usamos el operador '!' para asegurar al compilador que los valores no son nulos aquí.
        return BlocProvider(
            create: (context) => sl<GuideBloc>()
                ..add(GetGuideDataEvent(cafeteriaId!)), // Usamos '!' aquí
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Guía de Navegación'),
                ),
                body: SafeArea(
                    child: BlocBuilder<GuideBloc, GuideState>(
                        builder: (context, state) {
                            
                            // ... (Manejo de estados de carga, error y Loaded)
                            // La lógica de estado es la misma que la anterior, pero con el '!'
                            
                            if (state is GuideLoading) {
                                // Mostramos un encabezado provisional mientras carga
                                return Column(
                                    children: [
                                        GuideHeader(
                                            cafeteriaName: cafeteriaName!,
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
                                final currentCafeteria = state.cafeteria;
                                final currentUserLocation = state.userLocation;
                                final currentUserLocationName = state.userLocationName;

                                return Column(
                                    children: [
                                        GuideHeader(
                                            cafeteriaName: currentCafeteria.name,
                                            userLocationName: currentUserLocationName,
                                        ),
                                        Expanded(
                                            child: GuideMapWidget(
                                                cafeteria: currentCafeteria,
                                                userLocation: currentUserLocation,
                                            ),
                                        ),
                                    ],
                                );
                            }

                            // Fallback (debería ser inaccesible si isGuideReady es true)
                            return const SizedBox.shrink(); 
                        },
                    ),
                ),
            ),
        );
    }
}