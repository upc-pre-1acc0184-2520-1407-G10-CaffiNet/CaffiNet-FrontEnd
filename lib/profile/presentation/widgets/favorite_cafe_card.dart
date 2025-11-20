import 'package:flutter/material.dart';

import '../../data/models/favorite_cafe_model.dart';

class FavoriteCafeCard extends StatelessWidget {
  final FavoriteCafeModel fav;

  const FavoriteCafeCard({
    Key? key,
    required this.fav,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_cafe, size: 24),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fav.nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        (fav.rating ?? 0).toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${(fav.distancia ?? 0).toStringAsFixed(1)} mi',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  if (fav.categoria != null && fav.categoria!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      fav.categoria!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

           
            if (fav.nivel != null && fav.nivel!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.brown.shade300),
                ),
                child: Text(
                  fav.nivel!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.brown.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
