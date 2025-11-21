// lib/features/home/presentation/widgets/cafe_big_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/home_ui_models.dart';

class CafeBigCard extends StatelessWidget {
  final HomeCafeItem data;
  final LatLng? userLocation;

  const CafeBigCard({
    super.key,
    required this.data,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mapa
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(data.lat, data.lng),
                  initialZoom: 16,
                  minZoom: 3,
                  maxZoom: 18,
                  // Interacciones del mapa (drag + zoom + rueda del mouse)
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.scrollWheelZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'caffinet_app_flutter',
                  ),
                  MarkerLayer(
                    markers: [
                      // Ubicación del usuario
                      if (userLocation != null)
                        Marker(
                          width: 40,
                          height: 40,
                          point: userLocation!,
                          child: const Icon(
                            Icons.my_location,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      // Cafetería
                      Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(data.lat, data.lng),
                        child: const Icon(
                          Icons.local_cafe,
                          size: 34,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_rounded, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(label: data.level),
            ],
          ),
          const SizedBox(height: 8),
          // 👉 Tags reales de la cafetería
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in data.tags.take(6)) _Tag(tag),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                data.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '(${data.reviews})',
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.circle, size: 4),
              const SizedBox(width: 12),
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 4),
              Text(
                data.distanceLabel,
                style: const TextStyle(fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final map = {
      'Bronze': const Color(0xFFCD7F32),
      'Silver': const Color(0xFFC0C0C0),
      'Gold': const Color(0xFFFFD700),
    };
    final color = map[label] ?? Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
