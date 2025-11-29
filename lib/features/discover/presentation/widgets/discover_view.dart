import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Necesario para recalcular rápido

import '../blocs/discover_bloc.dart';
import '../blocs/discover_state.dart';
import '../blocs/discover_event.dart';
import '../widgets/filter_form_widget.dart';
import '../widgets/discover_result_widget.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  // Estado para controlar la visibilidad del formulario principal
  bool _showMainFilters = true;


  // 💡 COORDENADAS FIJAS PARA COLOMBIA (Plaza de Bolívar)
  static const _plazaBolivarLat = 4.59806;
  static const _plazaBolivarLng = -74.07609;

  // Estado local para los botones de país (Visual)
  String _selectedCountry = 'PE'; 

  // Variable para guardar la última ubicación conocida y no pedirla de nuevo innecesariamente
  Position? _lastKnownPosition;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverBloc, DiscoverState>(
      listener: (context, state) {
        if (state is DiscoverError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ ${state.message}')));
        }
        // Cuando hay éxito, ocultamos el formulario grande automáticamente
        if (state is DiscoverSuccess) {
          setState(() {
            _showMainFilters = false;
          });
        }
      },
      builder: (context, state) {
        final bool hasResult = state is DiscoverSuccess;
        final result = hasResult ? state.result : null;

        // Mapa base por defecto (Lima)
        final Widget baseMap = FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(-12.0464, -77.0428),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          ],
        );

        return Stack(
          children: [
            // ------------------------------------------------------
            // 1. CAPA DE FONDO (Mapa o Resultado)
            // ------------------------------------------------------
            Positioned.fill(
              child: hasResult && result != null
                  ? DiscoverResultWidget(
                      result: result,
                      // Ya no necesitamos callback de volver, el control está en pantalla
                      onBackToFilters: null, 
                    )
                  : baseMap,
            ),

            // ------------------------------------------------------
            // 2. FORMULARIO GRANDE (Solo visible al inicio o al editar todo)
            // ------------------------------------------------------
            if (_showMainFilters)
              Positioned(
                left: 16, right: 16, top: 16,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    height: 500, // Altura fija o dinámica según prefieras
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Filtros y Preferencias ⚙️', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Expanded(child: FilterFormWidget()),
                        // Botón pequeño para cerrar si el usuario quiere ver el mapa base sin calcular (opcional)
                        if (hasResult) 
                          TextButton(
                            onPressed: () => setState(() => _showMainFilters = false), 
                            child: const Text("Cerrar y ver mapa")
                          )
                      ],
                    ),
                  ),
                ),
              ),

            // ------------------------------------------------------
            // 3. BARRA DE CONTROL SUPERIOR (Visible cuando hay resultado)
            // ------------------------------------------------------
            if (!_showMainFilters && hasResult)
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // A) BOTONES DE PAÍS (Izquierda)
                        _buildCountryToggle(),

                        const SizedBox(width: 8),

                        // B) SELECTOR DE ALGORITMO FLOTANTE (Derecha/Centro)
                        //    Este widget permite cambiar el algoritmo al vuelo
                        Expanded(
                          child: _buildFloatingAlgorithmSelector(context, result!.selectedAlgorithm),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

             // 4. BOTÓN FLOTANTE PARA RE-ABRIR FILTROS COMPLETOS (Opcional, esquina inferior o superior)
             if (!_showMainFilters)
               Positioned(
                 right: 16,
                 top: 80, // Debajo de la barra de algoritmos
                 child: FloatingActionButton.small(
                   backgroundColor: Colors.white,
                   child: const Icon(Icons.tune, color: Colors.blueGrey),
                   onPressed: () {
                     setState(() {
                       _showMainFilters = true;
                     });
                   },
                 ),
               ),

            // Loading Overlay
            if (state is DiscoverLoading)
               Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 10),
                        Text("Recalculando ruta...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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

  void _changeCountry(String newCountry) async {
    final bloc = context.read<DiscoverBloc>();
    
    if (_selectedCountry != newCountry) {
        setState(() {
            _selectedCountry = newCountry;
        });

        // 1. Notificar al BLoC para reiniciar filtros y ubicación base
        bloc.add(CountryChanged(newCountryCode: newCountry));
        
        // 2. Ejecutar la acción específica de cada país y recalcular
        if (newCountry == 'PE') {
            // PERÚ: Usar la ubicación real del usuario
            try {
                // Obtenemos la ubicación actual del usuario
                final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                _lastKnownPosition = position;
                
                // Disparamos el cálculo con la nueva ubicación del usuario
                bloc.add(CalculateOptimalRoute(
                    userLat: position.latitude,
                    userLng: position.longitude,
                ));
            } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Error: No se pudo obtener la ubicación para Perú. Por favor, asegúrese de tener GPS activo.")));
            }
        } 
        else if (newCountry == 'CO') {
             // COLOMBIA: Usar la ubicación fija
             bloc.add(CalculateOptimalRoute(
                userLat: _plazaBolivarLat,
                userLng: _plazaBolivarLng,
             ));
        }
    }
  }

  // --- Widget: Toggle de Países ---
  Widget _buildCountryToggle() {
    // ... (Container y BoxDecoration) ...
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PERÚ
          InkWell(
            onTap: () => _changeCountry('PE'), // 💡 Llama a la nueva función
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCountry == 'PE' ? Colors.redAccent : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
              ),
              child: const Text('🇵🇪', style: TextStyle(fontSize: 18)),
            ),
          ),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          // COLOMBIA
          InkWell(
            onTap: () => _changeCountry('CO'), // 💡 Llama a la nueva función
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCountry == 'CO' ? Colors.yellow[700] : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
              ),
              child: const Text('🇨🇴', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Selector de Algoritmo Flotante ---
  Widget _buildFloatingAlgorithmSelector(BuildContext context, String currentAlgorithm) {
    final List<String> algorithms = ['Dijkstra', 'Floyd-Warshall', 'Bellman-Ford'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: algorithms.contains(currentAlgorithm) ? currentAlgorithm : algorithms.first,
                isDense: true,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: algorithms.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null && newValue != currentAlgorithm) {
                    _onAlgorithmChanged(context, newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Lógica: Recalcular Ruta al cambiar Algoritmo ---
  Future<void> _onAlgorithmChanged(BuildContext context, String newAlgorithm) async {
    final bloc = context.read<DiscoverBloc>();
    final currentState = bloc.state;

    // 1. Disparar evento de actualización de preferencias (siempre)
    bloc.add(PreferencesUpdated(
       currentFilters: currentState.currentPreferences.filters,
       selectedAlgorithm: newAlgorithm,
    ));

    // 2. Determinar la ubicación para el recálculo
    double lat, lng;
    
    if (_selectedCountry == 'CO') {
        // Colombia usa ubicación Fija
        lat = _plazaBolivarLat;
        lng = _plazaBolivarLng;
    } else {
        // Perú usa ubicación Real. Intentamos obtenerla de nuevo.
        try {
            Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
            _lastKnownPosition = position;
            lat = position.latitude;
            lng = position.longitude;
        } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo obtener ubicación para Perú. Recálculo cancelado.")));
             return; // Salir si falla la ubicación en Perú
        }
    }

    // 3. Recalcular
    bloc.add(CalculateOptimalRoute(
       userLat: lat,
       userLng: lng,
    ));
  }
}