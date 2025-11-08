import 'package:flutter/material.dart';

class HomePageViewModel extends ChangeNotifier {
  // Popular tags
  final List<TagItem> popularTags = [
    TagItem(name: 'Pet Friendly', icon: Icons.pets),
    TagItem(name: 'Free Wi-Fi', icon: Icons.wifi),
    TagItem(name: 'Peaceful', icon: Icons.mic_off),
    TagItem(name: 'More', icon: Icons.add),
  ];

  int _selectedTagIndex = -1;
  int get selectedTagIndex => _selectedTagIndex;

  void selectTag(int index) {
    _selectedTagIndex = index;
    notifyListeners();
  }

  // Suggested for you
  final List<SuggestedItem> suggestedItems = [
    SuggestedItem(
        name: 'Cafe Maria', distance: '1.8 mi', rating: 2.7, reviews: 127, level: 'Bronze'),
    SuggestedItem(
        name: 'Coffee House', distance: '2.2 mi', rating: 4.2, reviews: 98, level: 'Silver'),
    SuggestedItem(
        name: 'Latte Lounge', distance: '0.9 mi', rating: 4.8, reviews: 210, level: 'Gold'),
  ];
}

class TagItem {
  final String name;
  final IconData icon;
  TagItem({required this.name, required this.icon});
}

class SuggestedItem {
  final String name;
  final String distance;
  final double rating;
  final int reviews;
  final String level;
  SuggestedItem({
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.level,
  });
}