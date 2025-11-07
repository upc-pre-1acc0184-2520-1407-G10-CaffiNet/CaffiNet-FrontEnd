enum OpenStatus { open, closed }
enum CafeTier { bronze, silver, gold }

class SearchResult {
  final String id;
  final String name;
  final String address;
  final double rating;      
  final int ratingCount;    
  final double distanceMi;  
  final List<String> tags;  
  final OpenStatus status;  // abierto/cerrado
  final CafeTier tier;      // Bronze/Silver/Gold
  final String thumbnail;   // url de imagen

  const SearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.ratingCount,
    required this.distanceMi,
    required this.tags,
    required this.status,
    required this.tier,
    required this.thumbnail,
  });
}

class SearchFilters {
  final String query;
  final Set<String> selectedTags;
  const SearchFilters({
    this.query = '',
    this.selectedTags = const {},
  });

  SearchFilters copyWith({String? query, Set<String>? selectedTags}) {
    return SearchFilters(
      query: query ?? this.query,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

enum SortBy { rating, distance, name }

extension CafeTierX on CafeTier {
  String get label => switch (this) {
        CafeTier.bronze => 'Bronze',
        CafeTier.silver => 'Silver',
        CafeTier.gold => 'Gold',
      };
}
