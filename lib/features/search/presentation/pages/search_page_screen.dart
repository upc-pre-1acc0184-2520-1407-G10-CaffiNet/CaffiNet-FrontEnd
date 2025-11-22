import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_view_model.dart';
import '../../models/search_models.dart';
import '../widgets/search_input.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/result_list_item.dart';
import '../widgets/empty_state.dart';
import 'cafe_detail_page.dart';

// 1. DEFINIR EL CALLBACK (necesario para la comunicación con MainPage)
typedef GuideSelectedCallback = void Function(String id, String name);

class SearchPageScreen extends StatelessWidget {

  
  // 2. AÑADIR EL CAMPO DEL CALLBACK
  final GuideSelectedCallback onGuideSelected;

  // 3. MODIFICAR EL CONSTRUCTOR (dejar de ser const y requerir el callback)
  const SearchPageScreen({
    super.key,
    required this.onGuideSelected, // Se usa para inicializar el campo de arriba
    });
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SearchViewModel(userId: 1)
            ..loadCafeterias()
            ..loadFavorites(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Results'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Filters',
              onPressed: () => _openFilters(context),
            ),
          ],
        ),
        body: Consumer<SearchViewModel>(
          builder: (context, vm, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SearchInput(
                    value: vm.filters.query,
                    onChanged: vm.onQueryChanged,
                    onSubmitted: (_) => vm.search(),
                    onClear: () {
                      vm.clear();
                      vm.search();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '${vm.totalFound} coffeeShop found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        'Sort by: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      DropdownButton<SortBy>(
                        value: vm.sortBy,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                              value: SortBy.rating, child: Text('Rating')),
                          DropdownMenuItem(
                              value: SortBy.distance, child: Text('Distance')),
                          DropdownMenuItem(
                              value: SortBy.name, child: Text('Name')),
                        ],
                        onChanged: (s) => vm.setSort(s ?? SortBy.rating),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: FilterChipRow(
                    tags: const [
                      'Pet-friendly',
                      'Free Wi-Fi',
                      'Reservations',
                      'Gourmet',
                      'Parking Available',
                      'Music'
                    ],
                    selected: vm.filters.selectedTags.toList(),
                    onTap: (t) => vm.toggleTag(t),
                  ),
                ),

                if (vm.isSearching) const LinearProgressIndicator(),

                Expanded(
                  child: vm.results.isEmpty
                      ? const EmptyState(
                          message:
                              'Busca cafeterías por nombre, dirección o tag.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount:
                              vm.results.length + (vm.canLoadMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            if (i < vm.results.length) {
                              final result = vm.results[i];
                              return ResultListItem(
                                result: result,
                                isFavorite: vm.isFavorite(result.id),
                                onFavoriteTap: () =>
                                    vm.toggleFavorite(result.id),
                                // 4. LÓGICA DE NAVEGACIÓN CORREGIDA
                                onTap: () async {
                                  // Asumimos que quieres ver el detalle primero.
                                  // Si quieres ir a la guía directamente, omite el Navigator.push
                                  
                                  // 4.1. Navegar a la página de detalle (OPCIONAL, si sigue siendo necesario)
                                  final horario =
                                      await vm.getCafeteriaHorario(
                                          result.id);
                                  final calificaciones =
                                      await vm.getCafeteriaCalificaciones(
                                          result.id);
                                  
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CafeDetailPage(
                                        result: result, 
                                        horario: horario, 
                                        calificaciones: calificaciones,
                                        
                                        // PASANDO EL CALLBACK
                                        onGuideSelected: onGuideSelected, 
                                      ),
                                    ),
                                  );

                                  return Center(
                                    child: TextButton(
                                      onPressed: vm.loadMore,
                                      child: const Text('Load more results'),
                                    ),
                                  );
                                  
                                },
                              );
                            }
                            
                            return Center(
                              child: TextButton(
                                onPressed: vm.loadMore,
                                child: const Text('Load more results'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openFilters(BuildContext context) {
    final vm = context.read<SearchViewModel>();
    final allTags = const [
      'Pet Friendly',
      'Enchufes',
      'Wifi',
      'Terraza',
      'alegre',
      'calmada',
      'sin musica',
      'Tenue',
      'cálida',
      'brillante',
      'minimalista',
      'rustico',
      'vintage',
      'artistico',
      'industrial',
      'moderno',
      'Reservations',
      'Gourmet',
      'Parking Available',
      'Free Wi-Fi',
      'Music',
      'Specialty',
      'Wide',
      'Traditional',
      'Pet-friendly'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final selected = Set<String>.from(vm.filters.selectedTags);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allTags.map((t) {
                      final sel = selected.contains(t);
                      return FilterChip(
                        label: Text(t),
                        selected: sel,
                        onSelected: (_) {
                          setState(() {
                            sel ? selected.remove(t) : selected.add(t);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        for (final t in vm.filters.selectedTags.toList()) {
                          if (!selected.contains(t)) vm.toggleTag(t);
                        }
                        for (final t in selected) {
                          if (!vm.filters.selectedTags.contains(t)) {
                            vm.toggleTag(t);
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Search'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
