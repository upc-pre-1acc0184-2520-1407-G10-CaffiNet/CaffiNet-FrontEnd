
import 'package:flutter/material.dart';


class PopularTag {
  final IconData icon;
  final String name;
  final String filterKey; 

  const PopularTag({
    required this.icon,
    required this.name,
    required this.filterKey,
  });
}


class HomeCafeItem {
  final int id;
  final String name;

 
  final double lat;
  final double lng;


  final double distanceKm;

 
  final String distanceLabel;

  
  final double rating;
  final int reviews;

  
  final String level;


  final List<String> tags;

  
  final String? imageUrl;

  const HomeCafeItem({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.distanceLabel,
    required this.rating,
    required this.reviews,
    required this.level,
    required this.tags,
    this.imageUrl,
  });
}
