import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/search_models.dart';
import '../../service/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  final int? userId;

  SearchViewModel({this.userId});

  SearchFilters _filters = const SearchFilters();
  SortBy _sortBy = SortBy.rating;

  // Lista completa de resultados
  final List<SearchResult> _all = [];

 
  List<SearchResult> _page = [];
  bool _isSearching = false;
  int _nextIndex = 0;
  static const int _pageSize = 3;

  // Ubicación del usuario 
  Position? _userPosition;
  Position? get userPosition => _userPosition;

  // Favoritos
  final Set<String> _favoriteCafeteriaIds = {};
  bool _isLoadingFavorites = false;
  String? _favoritesError;

  SearchFilters get filters => _filters;
  SortBy get sortBy => _sortBy;
  bool get isSearching => _isSearching;
  List<SearchResult> get results => _page;
  int get totalFound => _filtered.length;
  bool get canLoadMore => _nextIndex < _filtered.length;

  Set<String> get favoriteCafeteriaIds => _favoriteCafeteriaIds;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String? get favoritesError => _favoritesError;

  

  Future<void> loadCafeterias() async {
    _isSearching = true;
    notifyListeners();
    try {
     
      await _ensureUserLocation();

      final List<SearchResult> response =
          await _searchService.getCafeterias();

      _all
        ..clear()
        ..addAll(response);

      
      _updateDistances();

      
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

  // Pide permisos y obtiene la posición actual del usuario
  Future<void> _ensureUserLocation() async {
    if (_userPosition != null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      
      if (kDebugMode) {
        print('Servicio de ubicación desactivado.');
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Permiso de ubicación denegado por el usuario.');
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('Permiso de ubicación denegado permanentemente.');
      }
      return;
    }

   
    _userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  
  void _updateDistances() {
    final pos = _userPosition;
    if (pos == null) {
      
      return;
    }

    for (var i = 0; i < _all.length; i++) {
      final r = _all[i];

      final miles = _distanceInMiles(
        pos.latitude,
        pos.longitude,
        r.latitude,
        r.longitude,
      );

      _all[i] = r.copyWith(distanceMi: miles);
    }
  }

  double _distanceInMiles(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    
    return distanceKm * 0.621371;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

 
  // Favoritos
 
  Future<void> loadFavorites() async {
    if (userId == null) return;

    _isLoadingFavorites = true;
    _favoritesError = null;
    notifyListeners();

    try {
      final ids = await _searchService.getFavoritos(userId!);
      _favoriteCafeteriaIds
        ..clear()
        ..addAll(ids);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error al cargar favoritos: $e\n$st');
      }
      _favoritesError = 'No se pudieron cargar tus favoritos.';
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(String cafeteriaId) {
    return _favoriteCafeteriaIds.contains(cafeteriaId);
  }

  Future<void> toggleFavorite(String cafeteriaId) async {
    if (userId == null) {
      if (kDebugMode) {
        print('toggleFavorite llamado sin userId, se ignora.');
      }
      return;
    }

    final alreadyFavorite = _favoriteCafeteriaIds.contains(cafeteriaId);

    
    if (alreadyFavorite) {
      _favoriteCafeteriaIds.remove(cafeteriaId);
    } else {
      _favoriteCafeteriaIds.add(cafeteriaId);
    }
    notifyListeners();

    try {
      if (alreadyFavorite) {
        await _searchService.removeFavorito(
          userId: userId!,
          cafeteriaId: cafeteriaId,
        );
      } else {
        await _searchService.addFavorito(
          userId: userId!,
          cafeteriaId: cafeteriaId,
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Error al actualizar favorito: $e\n$st');
      }

     
      if (alreadyFavorite) {
        _favoriteCafeteriaIds.add(cafeteriaId);
      } else {
        _favoriteCafeteriaIds.remove(cafeteriaId);
      }
      notifyListeners();
    }
  }



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
      final byText = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q);

      final byTags = _matchesTags(r, _filters.selectedTags);

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

 

  Future<CafeteriaSchedule?> getCafeteriaHorario(String id) =>
      _searchService.getCafeteriaHorario(id);

  Future<List<dynamic>> getCafeteriaCalificaciones(String id) =>
      _searchService.getCafeteriaCalificaciones(id);
}
