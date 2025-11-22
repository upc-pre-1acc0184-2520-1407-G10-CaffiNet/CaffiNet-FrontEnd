// lib/features/discover/presentation/pages/discover_page.dart

import 'package:caffinet_app_flutter/core/service/osrm_service.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/get_optimal_route_usecase.dart';
import 'package:caffinet_app_flutter/features/discover/presentation/widgets/discover_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/discover_bloc.dart';
// Asegúrate de importar DiscoverView


class DiscoverPage extends StatelessWidget {
  // Se requiere la dependencia del Usecase para inicializar el BLoC
  final GetOptimalRouteUseCase getOptimalRoute; 
  final OSRMService osrmService;
  const DiscoverPage({
      super.key, 
      required this.getOptimalRoute,
      required this.osrmService, 
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre la Ruta Óptima 🧭'),
        backgroundColor: Colors.blueGrey,
      ),
      // 1. Inyección de Dependencia: Provee el BLoC a todos los widgets hijos
      body: BlocProvider(
        // Aquí usa la dependencia para crear el BLoC
        create: (context) => DiscoverBloc(getOptimalRoute: getOptimalRoute, osrmService: osrmService),
        // 2. Muestra la vista que ahora maneja los paneles desplegables
        child: const DiscoverView(), 
      ),
    );
  }
}