import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:latlong2/latlong.dart';

import 'homrPage_view_model.dart';
import '../../models/home_ui_models.dart';
import '../widgets/cafe_big_card.dart';

import 'package:caffinet_app_flutter/features/search/models/search_models.dart';
import 'package:caffinet_app_flutter/features/search/presentation/pages/search_page_screen.dart';
import 'package:caffinet_app_flutter/features/search/presentation/pages/cafe_detail_page.dart';

typedef GuideSelectedCallback = void Function(String id, String name);

class HomePageScreen extends StatelessWidget {
  final VoidCallback? onGoToSearch;
  final GuideSelectedCallback onGuideSelected;

  /// ID del usuario logeado
  final int userId;

  const HomePageScreen({
    this.onGoToSearch,
    required this.onGuideSelected,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel()..init(),
      child: Scaffold(
        body: Consumer<HomePageViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const SafeArea(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (vm.errorMessage != null) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Something went wrong'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: vm.retry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Popular Tags
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(title: 'Popular Tags'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _PopularTags(vm: vm),
                    ),
                  ),

                  // Suggested
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: 'Suggested for You',
                        actionText: 'See all',
                        onTap: onGoToSearch,
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemCount: vm.suggestedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SuggestedItemCard(item: vm.suggestedItems[i]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Nearby
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: 'Nearby Coffe Shopp',
                        actionText: 'View all',
                        onTap: vm.nearestItem == null
                            ? null
                            : () => _goToNearbyDetail(
                                  context,
                                  vm.nearestItem!,
                                  onGuideSelected,
                                  userId, 
                                ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: _NearbyCard(
                        item: vm.nearestItem,
                        userLocation: vm.userLatLng,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

 
  static void _goToNearbyDetail(
    BuildContext context,
    HomeCafeItem item,
    GuideSelectedCallback onGuideSelected,
    int userId,
  ) {
    final tier = _tierFromLabel(item.level);

    final searchResult = SearchResult(
      id: item.id.toString(),
      name: item.name,
      address: 'Perú', 
      rating: item.rating,
      ratingCount: item.reviews,
      distanceMi: item.distanceKm * 0.621371,
      tags: item.tags,
      status: OpenStatus.open, 
      tier: tier,
      thumbnail: null,
      petFriendly: item.tags.contains('Pet Friendly'),
      hasWifi: item.tags.contains('Free Wi-Fi'),
      hasReservations: item.tags.contains('Reservations'),
      hasParking: item.tags.contains('Parking Available'),
      hasMusic: item.tags.any(
        (t) =>
            t.toLowerCase().contains('music') ||
            t.toLowerCase().contains('música'),
      ),
      latitude: item.lat,
      longitude: item.lng,
    );

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: CafeDetailPage(
        result: searchResult,
        horario: null,
        calificaciones: const [],
        onGuideSelected: onGuideSelected,
        userId: userId,
      ),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static CafeTier _tierFromLabel(String label) {
    switch (label) {
      case 'Gold':
        return CafeTier.gold;
      case 'Silver':
        return CafeTier.silver;
      case 'Bronze':
      default:
        return CafeTier.bronze;
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB56B56), Color(0xFFD7A18E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Good morning!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'What do you need drink today?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'What do you need drink today?',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleW = Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
    if (actionText == null) return titleW;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleW,
        InkWell(
          onTap: onTap,
          child: Text(
            actionText!,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _PopularTags extends StatelessWidget {
  final HomePageViewModel vm;
  const _PopularTags({required this.vm});

  @override
  Widget build(BuildContext context) {
    final HomePageScreen homePage =
        context.findAncestorWidgetOfExactType<HomePageScreen>()!;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vm.popularTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tag = vm.popularTags[index];
          final isSelected = vm.selectedTagIndex == index;
          final cs = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () {
              vm.selectTag(index);
              homePage.onGoToSearch?.call();
            },
            child: Container(
              width: 92,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withOpacity(.12)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? cs.primary : const Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tag.icon,
                    size: 24,
                    color: isSelected ? cs.primary : Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tag.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? cs.primary : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuggestedItemCard extends StatelessWidget {
  final HomeCafeItem item;
  const _SuggestedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_cafe, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Badge(label: item.level),
                ]),
                const SizedBox(height: 4),
                Text(
                  item.distanceLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ]),
              Text(
                '(${item.reviews})',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final HomeCafeItem? item;
  final LatLng? userLocation;

  const _NearbyCard({
    required this.item,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (item == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: const Center(
          child: Text('No nearby places yet'),
        ),
      );
    }

    return CafeBigCard(
      data: item!,
      userLocation: userLocation,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final map = {
      'Bronze': const Color(0xFFCD7F32),
      'Silver': const Color(0xFFC0C0C0),
      'Gold': const Color(0xFFFFD700),
    };
    final color = map[label] ?? Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
