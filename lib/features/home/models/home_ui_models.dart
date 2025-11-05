class CafeData {
  final String name;
  final String distance;
  final double rating;
  final int reviews;
  final String badge;
  final String imageUrl;
  final List<String> tags;

  const CafeData({
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.badge,
    required this.imageUrl,
    this.tags = const [],
  });
}

/// Mock de “Suggested for You”
const suggestedCafes = [
  CafeData(
    name: 'Cafe Maria',
    distance: '1.8 mi',
    rating: 2.7,
    reviews: 127,
    badge: 'Bronze',
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=600',
  ),
  CafeData(
    name: 'Cafe Lima',
    distance: '1.2 mi',
    rating: 4.7,
    reviews: 156,
    badge: 'Silver',
    imageUrl:
        'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?q=80&w=600',
  ),
];

/// Mock de “Nearby Coffe Shopp”
const nearbyCafe = CafeData(
  name: 'Puku Puku Narciso',
  distance: '0.5 mi',
  rating: 4.9,
  reviews: 1560,
  badge: 'Gold',
  imageUrl:
      'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?q=80&w=1000',
  tags: ['Free Wi-Fi', 'Specialty', 'Reservations', 'Parking Available'],
);
