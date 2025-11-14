import 'package:flutter/material.dart';
import '../../models/search_models.dart';

class ResultListItem extends StatelessWidget {
  final SearchResult result;
  final Function()? onTap; 

  const ResultListItem({
    super.key,
    required this.result,
    this.onTap,
  });

  Color _tierColor() {
    return switch (result.tier) {
      CafeTier.bronze => Colors.brown,
      CafeTier.silver => Colors.blueGrey,
      CafeTier.gold => Colors.amber,
    };
  }

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade300),
    );

    final statusIcon = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: result.status == OpenStatus.open ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(
        result.status == OpenStatus.open ? Icons.check : Icons.close,
        size: 16,
        color: Colors.white,
      ),
    );

    final tierColor = _tierColor();
    final String? imageUrl = result.thumbnail; 

    return Card(
      elevation: 0,
      shape: border,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.purple.shade100,
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl == null || imageUrl.isEmpty)
                        ? const Icon(Icons.local_cafe)
                        : null,
                  ),
                  Positioned(right: -2, top: -2, child: statusIcon),
                ],
              ),
              const SizedBox(width: 12),

              // Info
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
                            overflow: TextOverflow.ellipsis,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                
                    Wrap(
                      spacing: 6,
                      runSpacing: -6,
                      children:
                          result.tags.take(3).map((t) => _chip(t)).toList(),
                    ),
                    const SizedBox(height: 8),

                    // Rating + distancia
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${result.rating.toStringAsFixed(1)} (${result.ratingCount})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
