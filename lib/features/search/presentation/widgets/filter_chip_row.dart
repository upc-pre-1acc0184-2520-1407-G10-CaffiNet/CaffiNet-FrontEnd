import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> tags;
  final List<String> selected;
  final ValueChanged<String> onTap;

  const FilterChipRow({
    super.key,
    required this.tags,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 12),
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = tags[i];
          final isSel = selected.contains(t);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(t),
              selected: isSel,
              onSelected: (_) => onTap(t),
            ),
          );
        },
      ),
    );
  }
}
