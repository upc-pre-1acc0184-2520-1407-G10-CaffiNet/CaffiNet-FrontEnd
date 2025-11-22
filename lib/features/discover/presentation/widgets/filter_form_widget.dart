// lib/features/discover/presentation/widgets/filter_form_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // 💡 NECESARIO PARA LA UBICACIÓN REAL

import '../blocs/discover_bloc.dart';
import '../blocs/discover_event.dart';
import '../blocs/discover_state.dart';

// Asumimos que los eventos son:
// class PreferencesUpdated extends DiscoverEvent
// class CalculateOptimalRoute extends DiscoverEvent

class FilterFormWidget extends StatefulWidget {
  const FilterFormWidget({super.key});

  @override
  State<FilterFormWidget> createState() => _FilterFormWidgetState();
}

class _FilterFormWidgetState extends State<FilterFormWidget> {
  Map<String, dynamic> _currentFilters = {};
  String _selectedAlgorithm = 'Dijkstra'; 
  bool _isLoadingLocation = false; // Nuevo estado para el botón de carga

  final List<String> _algorithmOptions = ['Dijkstra', 'Floyd-Warshall', 'Bellman-Ford'];
  final List<String> _musicOptions = ['alegre', 'calmada', 'sin música'];
  final List<String> _presentationOptions = ['Molido', 'Cápsula', 'Grano'];

  @override
  void initState() {
    super.initState();
    // Inicialización de filtros (código original)
    final initialState = BlocProvider.of<DiscoverBloc>(context).state;
    if (initialState is DiscoverInitial) {
      _currentFilters = initialState.currentPreferences.filters;
      _selectedAlgorithm = initialState.currentPreferences.algorithm;
    }
  }

  void _updatePreferences() {
    // Dispara el evento para guardar los filtros seleccionados (código original)
    BlocProvider.of<DiscoverBloc>(context).add(
      PreferencesUpdated(
        currentFilters: _currentFilters,
        selectedAlgorithm: _selectedAlgorithm,
      ),
    );
  }

  // 💡 LÓGICA CORREGIDA PARA OBTENER LA UBICACIÓN REAL
  Future<void> _onCalculate() async {
    if (_isLoadingLocation) return;
    
    // 1. Iniciar estado de carga visual
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 2. Verificar permisos de servicio y ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Servicio de ubicación deshabilitado. Actívalo para continuar.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('Permisos de ubicación denegados. No podemos obtener tu posición.');
        }
      }

      // 3. Obtener la posición actual (alta precisión)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // 4. Disparar el evento de cálculo con las coordenadas reales
      BlocProvider.of<DiscoverBloc>(context).add(
        CalculateOptimalRoute(
          userLat: position.latitude, 
          userLng: position.longitude,
        ),
      );

    } catch (e) {
      // Manejo de errores de ubicación (permisos, servicios, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🛑 Error de Ubicación: ${e.toString().split(':')[1].trim()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 5. Finalizar estado de carga visual
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Selector de Algoritmo (CÓDIGO ORIGINAL)
          _buildDropdownFilter(
            label: 'Algoritmo de Optimización',
            value: _selectedAlgorithm,
            options: _algorithmOptions,
            onChanged: (newValue) {
              setState(() {
                _selectedAlgorithm = newValue!;
                _updatePreferences();
              });
            },
          ),
          const Divider(height: 30),

          // 2. Filtros de Tags (CÓDIGO ORIGINAL)
          const Text('Filtros de Ambiente y Servicio:', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildCheckboxFilter(label: 'Pet Friendly', keyName: 'pet_friendly'),
          _buildCheckboxFilter(label: 'WiFi', keyName: 'wifi'),
          _buildDropdownFilter(
            label: 'Tipo de Música',
            value: _currentFilters['tipo_musica'] ?? _musicOptions.first,
            options: _musicOptions,
            keyName: 'tipo_musica',
            onChanged: (newValue) {
               setState(() {
                _currentFilters['tipo_musica'] = newValue;
                _updatePreferences();
              });
            },
          ),
          const Divider(height: 30),

          // 3. Botón de Acción (CORREGIDO PARA MOSTRAR CARGA)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              // Deshabilita el botón si ya está cargando
              onPressed: _isLoadingLocation ? null : _onCalculate,
              icon: _isLoadingLocation 
                  ? const SizedBox(
                      width: 18, 
                      height: 18, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.compare_arrows),
              label: Text(_isLoadingLocation ? 'Obteniendo Ubicación...' : 'Calcular Ruta Óptima'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Métodos de Construcción Auxiliares ---

  Widget _buildCheckboxFilter({required String label, required String keyName}) {
    return CheckboxListTile(
      title: Text(label),
      value: _currentFilters[keyName] ?? false,
      onChanged: (bool? newValue) {
        setState(() {
          _currentFilters[keyName] = newValue!;
          _updatePreferences();
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> options,
    String? keyName,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: options.contains(value) ? value : null,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (newValue) {
        if (keyName != null) {
          _currentFilters[keyName] = newValue;
        }
        onChanged(newValue);
      },
    );
  }
}