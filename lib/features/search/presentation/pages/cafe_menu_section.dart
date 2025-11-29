import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://127.0.0.1:8000';

class CafeMenuSection extends StatefulWidget {
  final String cafeteriaId;

  const CafeMenuSection({
    super.key,
    required this.cafeteriaId,
  });

  @override
  State<CafeMenuSection> createState() => _CafeMenuSectionState();
}

enum _MenuSortOrder { lowToHigh, highToLow }

class _CafeMenuSectionState extends State<CafeMenuSection> {
  bool _isOpen = false;
  bool _isLoading = false;
  String? _error;

  _MenuSortOrder _sortOrder = _MenuSortOrder.lowToHigh;

  final List<_BeverageItem> _beverages = [];
  final List<_ProductItem> _products = [];

  bool _showBeverages = true;
  bool _showProducts = true;

  Future<void> _onTogglePressed() async {
    // Si la carta está cerrada y todavía no hay datos, cargamos del backend
    if (!_isOpen && _beverages.isEmpty && _products.isEmpty) {
      await _loadMenu();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Endpoints del backend
      final bebidasFuture = http.get(
        Uri.parse('$_baseUrl/cafeterias-bebidas/${widget.cafeteriaId}'),
      );
      final productosFuture = http.get(
        Uri.parse('$_baseUrl/cafeterias-productos/${widget.cafeteriaId}'),
      );

      final responses = await Future.wait([bebidasFuture, productosFuture]);

      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) {
        throw Exception('Error en el servidor');
      }

      final bebidasJson = json.decode(responses[0].body) as List;
      final productosJson = json.decode(responses[1].body) as List;

      _beverages
        ..clear()
        ..addAll(
          bebidasJson
              .whereType<Map<String, dynamic>>()
              .map((e) => _BeverageItem.fromJson(e)),
        );

      _products
        ..clear()
        ..addAll(
          productosJson
              .whereType<Map<String, dynamic>>()
              .map((e) => _ProductItem.fromJson(e)),
        );

      _applySorting();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applySorting() {
    int compare(double a, double b) {
      if (_sortOrder == _MenuSortOrder.lowToHigh) {
        return a.compareTo(b);
      } else {
        return b.compareTo(a);
      }
    }

    _beverages.sort((a, b) => compare(a.price, b.price));
    _products.sort((a, b) => compare(a.price, b.price));
  }

  void _onSortChanged(_MenuSortOrder order) {
    setState(() {
      _sortOrder = order;
      _applySorting();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _onTogglePressed,
          child: Text(_isOpen ? 'Ocultar carta' : 'Ver carta'),
        ),
        if (_isOpen) ...[
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Error al cargar la carta: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (!_isLoading && _error == null) _buildMenuContent(context),
        ],
      ],
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasAnyItem = _beverages.isNotEmpty || _products.isNotEmpty;

    if (!hasAnyItem) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Esta cafetería aún no tiene carta registrada.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título + Sort por precio
        Row(
          children: [
            Text(
              'Carta',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            PopupMenuButton<_MenuSortOrder>(
              initialValue: _sortOrder,
              onSelected: _onSortChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuSortOrder.lowToHigh,
                  child: Text('Precio: bajo a alto'),
                ),
                PopupMenuItem(
                  value: _MenuSortOrder.highToLow,
                  child: Text('Precio: alto a bajo'),
                ),
              ],
              child: Row(
                children: [
                  Text(
                    _sortOrder == _MenuSortOrder.lowToHigh
                        ? 'Sort by: Precio ↑'
                        : 'Sort by: Precio ↓',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Chips Bebidas / Productos
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Bebidas'),
              selected: _showBeverages,
              onSelected: (value) {
                setState(() {
                  _showBeverages = value;
                });
              },
            ),
            FilterChip(
              label: const Text('Productos'),
              selected: _showProducts,
              onSelected: (value) {
                setState(() {
                  _showProducts = value;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_showBeverages && _beverages.isNotEmpty) ...[
          Text(
            'Bebidas',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          for (final b in _beverages)
            _MenuCard(
              title: b.name,
              subtitle:
                  '${b.size}${b.milk.isNotEmpty ? ' · ${b.milk}' : ''}',
              categoryChip: 'Bebidas',
              price: b.price,
              leadingIcon: Icons.local_cafe,
            ),
          const SizedBox(height: 12),
        ],

        if (_showProducts && _products.isNotEmpty) ...[
          Text(
            'Productos',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          for (final p in _products)
            _MenuCard(
              title: p.name,
              subtitle: p.type,
              categoryChip: 'Productos',
              price: p.price,
              leadingIcon: Icons.local_dining,
            ),
        ],
      ],
    );
  }
}

/* MODELOS & UTILIDADES  */

double _parsePrice(dynamic raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  final s = raw.toString().trim().replaceAll(',', '.');
  return double.tryParse(s) ?? 0;
}

class _BeverageItem {
  final String name;
  final String size;
  final String milk;
  final String category;
  final double price;

  _BeverageItem({
    required this.name,
    required this.size,
    required this.milk,
    required this.category,
    required this.price,
  });

  factory _BeverageItem.fromJson(Map<String, dynamic> json) {
    final rawName =
        json['Bebida'] ?? json['bebida'] ?? json['nombre_bebida'] ?? json['nombre'];

    final rawSize = json['Tamaño'] ??
        json['tamano'] ??
        json['tamaño'] ??
        json['size'];

    final rawMilk = json['Leche'] ?? json['leche'] ?? json['tipo_leche'];

    final rawCategory =
        json['Categoria'] ?? json['categoria'] ?? json['category'];

    final rawPrice = json['precio'] ?? json['Precio'] ?? json['price'];

    return _BeverageItem(
      name: rawName?.toString() ?? '',
      size: rawSize?.toString() ?? '',
      milk: rawMilk?.toString() ?? '',
      category: rawCategory?.toString() ?? '',
      price: _parsePrice(rawPrice),
    );
  }
}

class _ProductItem {
  final String name;
  final String type;
  final String category;
  final double price;

  _ProductItem({
    required this.name,
    required this.type,
    required this.category,
    required this.price,
  });

  factory _ProductItem.fromJson(Map<String, dynamic> json) {
    final rawName =
        json['nombre_producto'] ?? json['producto'] ?? json['nombre'];

    final rawType = json['tipo'] ?? json['category'] ?? '';

    final rawCategory =
        json['categoria'] ?? json['Categoria'] ?? json['category'];

    final rawPrice = json['precio'] ?? json['Precio'] ?? json['price'];

    return _ProductItem(
      name: rawName?.toString() ?? '',
      type: rawType?.toString() ?? '',
      category: rawCategory?.toString() ?? '',
      price: _parsePrice(rawPrice),
    );
  }
}

/* CARD */

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String categoryChip;
  final double price;
  final IconData leadingIcon;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.categoryChip,
    required this.price,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(leadingIcon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(categoryChip),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

