import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const SearchInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    controller.selection =
        TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search ',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value.isNotEmpty
            ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
