import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/search_models.dart';

class SearchViewModel extends ChangeNotifier {
  
  SearchFilters _filters = const SearchFilters();
  SortBy _sortBy = SortBy.rating;
  final List<SearchResult> _all = _mockData; 
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

  List<SearchResult> get _filtered {
    final q = _filters.query.trim().toLowerCase();
    final filtered = _all.where((r) {
      final byText = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q);
      final byTags = _filters.selectedTags.isEmpty ||
          _filters.selectedTags.every((t) => r.tags.contains(t));
      return byText && byTags;
    }).toList();

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

 
  static const List<SearchResult> _mockData = [
    SearchResult(
      id: '1',
      name: 'Cafe Maria',
      address: 'Av. Central 123',
      rating: 2.7,
      ratingCount: 127,
      distanceMi: 0.5,
      tags: ['Music', 'Free Wi-Fi', 'Pet-friendly', 'Wide', 'Traditional'],
      status: OpenStatus.open,
      tier: CafeTier.bronze,
      thumbnail: 'https://images.unsplash.com/photo-1498804103079-a6351b050096?q=80&w=300',
    ),
    SearchResult(
      id: '2',
      name: 'Cafe de Lima',
      address: 'Los Olivos',
      rating: 4.7,
      ratingCount: 156,
      distanceMi: 0.5,
      tags: ['Music', 'Gourmet', 'Reservations', 'Pet-friendly'],
      status: OpenStatus.open,
      tier: CafeTier.silver,
      thumbnail: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?q=80&w=300',
    ),
    SearchResult(
      id: '3',
      name: 'Puku Puku Narciso',
      address: 'Miraflores',
      rating: 4.9,
      ratingCount: 1560,
      distanceMi: 0.5,
      tags: ['Free Wi-Fi', 'Specialty', 'Reservations', 'Parking Available'],
      status: OpenStatus.open,
      tier: CafeTier.gold,
      thumbnail: 'https://images.unsplash.com/photo-1461988091159-192b6df7054f?q=80&w=300',
    ),
    SearchResult(
      id: '4',
      name: 'Le Cafe Swissôtel Lima',
      address: 'San Isidro',
      rating: 4.3,
      ratingCount: 1560,
      distanceMi: 0.5,
      tags: ['Reservations', 'Parking Available'],
      status: OpenStatus.closed, 
      tier: CafeTier.gold,
      thumbnail: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=300',
    ),
  ];
}
