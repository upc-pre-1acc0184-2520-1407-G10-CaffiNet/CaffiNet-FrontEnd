import 'package:flutter/material.dart';
import '../../models/search_models.dart';

class CafeDetailPage extends StatelessWidget {
  final SearchResult result;
  const CafeDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final tierColor = switch (result.tier) {
      CafeTier.bronze => Colors.brown,
      CafeTier.silver => Colors.blueGrey,
      CafeTier.gold => Colors.amber,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Search Result'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Card resumen
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
                        backgroundImage: NetworkImage(result.thumbnail),
                      ),
                      Positioned(
                        right: -2, top: -2,
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: result.status == OpenStatus.open ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            result.status == OpenStatus.open ? Icons.check : Icons.close,
                            size: 16, color: Colors.white),
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
                              child: Text(result.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          spacing: 6, runSpacing: -6,
                          children: result.tags.take(3).map((t) =>
                            Chip(
                              label: Text(t, style: const TextStyle(fontSize: 12)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${result.rating.toStringAsFixed(1)} (${result.ratingCount})'),
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
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(result.address),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('10:00 am - 11:00 pm'), // mock
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Monday, Tuesday, Wednesday, Thursday, Friday'), // mock
          ),

          const SizedBox(height: 8),
          Text('Map', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // Mapa placeholder
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
          FilledButton(
            onPressed: () {
              // TODO: Navegar a tu flujo "Guide"
            },
            child: const Text('Guide'),
          ),
        ],
      ),
    );
  }
}
