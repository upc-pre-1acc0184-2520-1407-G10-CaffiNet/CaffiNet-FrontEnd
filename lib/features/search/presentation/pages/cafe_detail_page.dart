import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../../models/search_models.dart';
import 'cafe_menu_section.dart';

class CafeDetailPage extends StatelessWidget {
  final SearchResult result;
  final CafeteriaSchedule? horario;        
  final List<dynamic> calificaciones;      
  
  const CafeDetailPage({
    super.key,
    required this.result,
    required this.horario,
    required this.calificaciones,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = switch (result.tier) {
      CafeTier.bronze => Colors.brown,
      CafeTier.silver => Colors.blueGrey,
      CafeTier.gold => Colors.amber,
    };

    // Imagen segura
    final String? imageUrl = result.thumbnail;

    // Campos de horario seguros
    final String? openTime = horario?.horaApertura;
    final String? closeTime = horario?.horaCierre;
    final String? days = horario?.diasAbre;

    final String horarioTexto = (openTime != null && closeTime != null)
        ? '$openTime - $closeTime'
        : 'Horario no disponible';

    // Posición del mapa
    final bool hasValidCoords =
        result.latitude != 0 && result.longitude != 0;
    final latlng.LatLng cafePosition =
        latlng.LatLng(result.latitude, result.longitude);

    final bool hasAddress = result.address.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Result'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Información principal de la cafetería
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.purple.shade100,
                        backgroundImage:
                            (imageUrl != null && imageUrl.isNotEmpty)
                                ? NetworkImage(imageUrl)
                                : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(Icons.local_cafe)
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: result.status == OpenStatus.open
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            result.status == OpenStatus.open
                                ? Icons.check
                                : Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                result.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tierColor),
                              ),
                              child: Text(
                                result.tier.label,
                                style: TextStyle(
                                  color: tierColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: result.tags
                              .take(3)
                              .map(
                                (t) => Chip(
                                  label: Text(
                                    t,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: BorderSide(
                                      color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                                '${result.rating.toStringAsFixed(1)} (${result.ratingCount})'),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 4),
                            Text('${result.distanceMi.toStringAsFixed(1)} mi'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Descripción de la cafetería
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Dirección + coordenadas
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(
              hasAddress
                  ? result.address
                  : hasValidCoords
                      ? 'Ubicación disponible en el mapa'
                      : 'Dirección no disponible',
            ),
            subtitle: hasValidCoords
                ? Text(
                    '${result.latitude.toStringAsFixed(5)}, '
                    '${result.longitude.toStringAsFixed(5)}',
                  )
                : null,
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(horarioTexto),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(days ?? 'Días no disponibles'),
          ),

          const SizedBox(height: 8),

          // 🔹 NUEVA SECCIÓN: "VER CARTA"
          CafeMenuSection(
            cafeteriaId: result.id, // tu id es String
          ),

          const SizedBox(height: 16),

          // Mapa
          Text('Map', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          if (hasValidCoords)
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: cafePosition,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.caffinet_app_flutter',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: cafePosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Center(
                child: Icon(Icons.map_outlined, size: 48),
              ),
            ),

          const SizedBox(height: 16),

          // Botón para guía (placeholder)
          FilledButton(
            onPressed: () {
              // Aquí podrías abrir un intent / URL externo
            },
            child: const Text('Guide'),
          ),

          const SizedBox(height: 16),

          // Calificaciones
          Text('Ratings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...calificaciones.map<Widget>((cal) {
            final rating = cal is Map && cal['rating'] != null
                ? cal['rating'].toString()
                : '-';
            final comment = cal is Map && cal['comment'] != null
                ? cal['comment'].toString()
                : '';
            return ListTile(
              title: Text('Rating: $rating'),
              subtitle: Text(comment),
            );
          }).toList(),
        ],
      ),
    );
  }
}
