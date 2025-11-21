import 'package:flutter/material.dart';

class TagChipsRow extends StatelessWidget {
  const TagChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const tags = [
      ('Pet Friendly', Icons.pets),
      ('Free-Fi', Icons.wifi),
      ('Peaceful', Icons.spa),
      ('More', Icons.add),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags
          .map((t) => _TagChip(label: t.$1, icon: t.$2))
          .toList(),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TagChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
