import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/discover_bloc.dart';
import '../blocs/discover_state.dart';
import '../blocs/discover_event.dart';
import '../widgets/filter_form_widget.dart';
import '../widgets/discover_result_widget.dart';
// Asegúrate de importar la entidad de resultado aquí si es necesario
// import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result_entity.dart'; 


// --------------------------------------------------------------------------
// 🚀 DiscoverView ahora es Stateful para manejar el estado de las expansiones
// --------------------------------------------------------------------------

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  // Estado para controlar la visibilidad del formulario (se mantiene sobre el mapa)
  bool _showFilters = true;
  // Estado para controlar si el panel de filtros está expandido
  bool _filtersExpanded = false;

  /// Método para volver a los filtros (reset del estado)
  void _backToFilters() {
    setState(() {
      _showFilters = true;
      _filtersExpanded = false;
    });
    // Emitir evento para volver al estado inicial
    context.read<DiscoverBloc>().add(
      PreferencesUpdated(
        currentFilters: {},
        selectedAlgorithm: 'Dijkstra',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El BlocConsumer escucha cambios de estado y muestra errores/actualizaciones
    return BlocConsumer<DiscoverBloc, DiscoverState>(
      listener: (context, state) {
        if (state is DiscoverError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ ${state.message}')));
        }
        // Cuando hay resultado, escondemos filtros para dar más pantalla al mapa
        if (state is DiscoverSuccess) {
          setState(() => _showFilters = false);
        }
      },
      builder: (context, state) {
        final bool hasResult = state is DiscoverSuccess;
        final result = hasResult ? state.result : null;

        // Mapa base (si no hay resultado mostramos un mapa vacío centrado en 0,0)
        final Widget baseMap = FlutterMap(
          options: MapOptions(
            initialCenter: hasResult && result != null && result.orderedCafeterias.isNotEmpty
                ? LatLng(result.orderedCafeterias.first.latitude, result.orderedCafeterias.first.longitude)
                : LatLng(0, 0),
            initialZoom: 2.0,
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.caffinet_app_flutter'),
          ],
        );

        return Stack(
          children: [
            // 1) Mapa en fondo (o el widget de resultado que ya pinta su propio mapa si hay resultado)
            Positioned.fill(
              child: hasResult && result != null
                  ? DiscoverResultWidget(
                      result: result,
                      onBackToFilters: _backToFilters,
                    )
                  : baseMap,
            ),

            // 1.5) Botón "Volver a Filtros" en la esquina superior derecha (solo si hay resultado)
            if (hasResult)
              Positioned(
                right: 16,
                top: 16,
                child: FloatingActionButton.small(
                  heroTag: 'backToFilters',
                  onPressed: _backToFilters,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  tooltip: 'Volver a Filtros',
                  child: const Icon(Icons.edit),
                ),
              ),

            // 2) Filtros arriba como overlay (tap para expandir)
            if (_showFilters)
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showFilters ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _filtersExpanded ? 420 : 160,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // Header para indicar que puede expandirse
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Filtros y Preferencias ⚙️', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Icon(_filtersExpanded ? Icons.expand_less : Icons.expand_more),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Formulario real (expandible)
                              Expanded(child: const FilterFormWidget()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Overlay de carga cuando el estado es DiscoverLoading
            if (state is DiscoverLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Calculando la ruta...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}