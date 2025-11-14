import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/search_models.dart';
import '../../service/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  SearchFilters _filters = const SearchFilters();
  SortBy _sortBy = SortBy.rating;

  // Lista completa traída del backend
  final List<SearchResult> _all = [];

 
  List<SearchResult> _page = [];
  bool _isSearching = false;
  int _nextIndex = 0;
  static const int _pageSize = 3;

  SearchFilters get filters => _filters;
  SortBy get sortBy => _sortBy;
  bool get isSearching => _isSearching;
  List<SearchResult> get results => _page;
  int get totalFound => _filtered.length;
  bool get canLoadMore => _nextIndex < _filtered.length;

  //  CARGAR DESDE BACKEND 
  Future<void> loadCafeterias() async {
    _isSearching = true;
    notifyListeners();
    try {
      final List<SearchResult> response =
          await _searchService.getCafeterias(); 

      _all
        ..clear()
        ..addAll(response);

      await search();
    } catch (e, st) {
      if (kDebugMode) {
        print('Error en loadCafeterias: $e\n$st');
      }
      throw Exception('Failed to load cafeterias');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  //  LÓGICA DE BÚSQUEDA 
  void onQueryChanged(String q) {
    _filters = _filters.copyWith(query: q);
    _resetAndSearch();
  }

  void toggleTag(String tag) {
    final tags = Set<String>.from(_filters.selectedTags);
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    _filters = _filters.copyWith(selectedTags: tags);
    _resetAndSearch();
  }

  void setSort(SortBy s) {
    _sortBy = s;
    _resetAndSearch();
  }

  Future<void> search() async {
    _isSearching = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _page = _filtered.take(_pageSize).toList();
    _nextIndex = _page.length;
    _isSearching = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    _isSearching = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final end = min(_nextIndex + _pageSize, _filtered.length);
    _page = [..._page, ..._filtered.sublist(_nextIndex, end)];
    _nextIndex = end;
    _isSearching = false;
    notifyListeners();
  }

  void clear() {
    _filters = const SearchFilters();
    _sortBy = SortBy.rating;
    _page = [];
    _nextIndex = 0;
    notifyListeners();
  }

  void _resetAndSearch() {
    _page = [];
    _nextIndex = 0;
    search();
  }

  //  FILTRO (texto + tags)
  List<SearchResult> get _filtered {
    final q = _filters.query.trim().toLowerCase();

    bool _matchesTags(SearchResult r, Set<String> selected) {
      if (selected.isEmpty) return true;

      for (final tag in selected) {
        switch (tag) {
          case 'Pet-friendly':
            if (!r.petFriendly) return false;
            break;
          case 'Free Wi-Fi':
            if (!r.hasWifi) return false;
            break;
          case 'Reservations':
            if (!r.hasReservations) return false;
            break;
          case 'Parking Available':
            if (!r.hasParking) return false;
            break;
          case 'Music':
            if (!r.hasMusic) return false;
            break;
          default:
            
            if (!r.tags.contains(tag)) return false;
        }
      }
      return true;
    }

    final filtered = _all.where((r) {
      // Filtro por texto (nombre o dirección)
      final byText = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q);

      // Filtro por tags seleccionados
      final byTags = _matchesTags(r, _filters.selectedTags);

      return byText && byTags;
    }).toList();

    // Ordenamiento
    filtered.sort((a, b) {
      switch (_sortBy) {
        case SortBy.rating:
          final cmp = b.rating.compareTo(a.rating);
          return cmp != 0 ? cmp : b.ratingCount.compareTo(a.ratingCount);
        case SortBy.distance:
          return a.distanceMi.compareTo(b.distanceMi);
        case SortBy.name:
          return a.name.compareTo(b.name);
      }
    });
    return filtered;
  }

  //  MÉTODOS PARA DETALLE 

  Future<CafeteriaSchedule?> getCafeteriaHorario(String id) =>
      _searchService.getCafeteriaHorario(id);

  Future<List<dynamic>> getCafeteriaCalificaciones(String id) =>
      _searchService.getCafeteriaCalificaciones(id);
}
