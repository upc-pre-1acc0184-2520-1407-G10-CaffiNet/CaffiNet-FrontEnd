import 'package:flutter/material.dart';
import 'package:caffinet_app_flutter/features/discover/domain/entities/optimal_route_result.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DiscoverResultWidget extends StatefulWidget {
  final OptimalRouteResult result;

  const DiscoverResultWidget({super.key, required this.result});

  @override
  State<DiscoverResultWidget> createState() => _DiscoverResultWidgetState();
}

class _DiscoverResultWidgetState extends State<DiscoverResultWidget> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final MapController _mapController = MapController(); // 1. CONTROLADOR AÑADIDO
  bool _sheetExpanded = false;

  OptimalRouteResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    // 2. Ejecutar el centrado después de que el widget se ha renderizado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBoundsToRoute(); 
    });
  }

  // --- Lógica de Centrado y Zoom (Ajuste de límites) ---

  void _fitBoundsToRoute() {
    final allPoints = <LatLng>[];

    // 1. Recolección de puntos
    if (result.realRoutePoints.isNotEmpty) {
      allPoints.addAll(result.realRoutePoints);
    } else if (result.orderedCafeterias.isNotEmpty) {
      allPoints.addAll(result.orderedCafeterias.map((c) => LatLng(c.latitude, c.longitude)));
    }

    if (allPoints.isEmpty) return;
    
    // Caso de un solo punto
    if (allPoints.length == 1) {
        _mapController.move(allPoints.first, 13.0);
        return;
    }

    // 2. Crear LatLngBounds
    final bounds = LatLngBounds.fromPoints(allPoints);

    // 3. Crear el objeto CameraFit con el padding para el DraggableSheet
    final cameraFit = CameraFit.bounds(
      bounds: bounds,
      // Padding para dejar espacio para el DraggableSheet
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 250), 
      maxZoom: 16.0,
    );

    // 🛑 CORRECCIÓN FINAL: Usar el método fitCamera() con el objeto CameraFit
    // Este método mueve y hace zoom al mapa automáticamente.
    _mapController.fitCamera(cameraFit); 
  }
  // --- Helpers de Renderizado ---

  Polyline _buildRoutePolyline() {
    final routePoints = <LatLng>[];

    if (result.realRoutePoints.isNotEmpty) {
      // Usar los puntos de OSRM (curvos)
      routePoints.addAll(result.realRoutePoints);
    } else {
      // Fallback: Trazar línea recta entre las cafeterías (usando la entidad)
      routePoints.addAll(result.orderedCafeterias.map((c) => LatLng(c.latitude, c.longitude)));
    }

    return Polyline(
      points: routePoints,
      color: Colors.red,
      strokeWidth: 4.0,
    );
  }

  List<Marker> _buildMarkers() {
    return result.orderedCafeterias.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final cafe = entry.value;

      return Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(cafe.latitude, cafe.longitude), 
        
        // 🛑 CORRECCIÓN: Usar 'child' en lugar de 'builder'
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.blue,
              child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
            const Icon(Icons.location_pin, color: Colors.blue, size: 24),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildMetadataRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text('$title ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  // --- Widget Build ---

  @override
  Widget build(BuildContext context) {
    // Calcular un centro inicial (solo como valor de partida, luego _fitBoundsToRoute lo corrige)
    LatLng initialCenter = result.orderedCafeterias.isNotEmpty
        ? LatLng(result.orderedCafeterias.first.latitude, result.orderedCafeterias.first.longitude)
        : const LatLng(0, 0);

    return Stack(
      children: [
        // 3. WIDGET DE MAPA
        FlutterMap(
          mapController: _mapController, // 🛑 Asignar el MapController
          options: MapOptions(
            initialCenter: initialCenter, // 🛑 Usar initialCenter
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.caffinet_app_flutter',
            ),
            PolylineLayer(polylines: [_buildRoutePolyline()]),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        
        // 4. SHEET DESLIZABLE
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.25,
          minChildSize: 0.12,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () {
                // Lógica de expansión/colapso
                double targetSize = _sheetExpanded ? 0.25 : 0.85;
                _sheetController.animateTo(targetSize, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                setState(() => _sheetExpanded = !_sheetExpanded);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Metadatos del Algoritmo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('✅ Ruta Calculada por: ${result.selectedAlgorithm}', style: Theme.of(context).textTheme.titleMedium)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Tiempo de Proceso: ${result.processingTime.inMilliseconds} ms', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Complejidad (Big O): ${result.bigONotation}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      // Lista de Cafeterías
                      Text(
                          'Cafeterías Ordenadas (${result.orderedCafeterias.length})', 
                          style: Theme.of(context).textTheme.titleLarge
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: result.orderedCafeterias.length,
                        itemBuilder: (context, index) {
                          final item = result.orderedCafeterias[index];
                          return ListTile(
                            leading: CircleAvatar(
                                backgroundColor: Colors.blue, 
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white))
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Coste Óptimo: ${item.optimalCost.toStringAsFixed(2)}'),
                            trailing: const Icon(Icons.near_me),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}