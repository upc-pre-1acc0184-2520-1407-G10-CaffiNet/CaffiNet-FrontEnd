import 'package:caffinet_app_flutter/core/di/injector.dart';
import 'package:caffinet_app_flutter/core/service/osrm_service.dart';
import 'package:caffinet_app_flutter/features/guide/presentation/pages/guide_page.dart';
import 'package:caffinet_app_flutter/features/home/presentation/pages/homePage_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:caffinet_app_flutter/features/search/presentation/pages/search_page_screen.dart';
import 'package:caffinet_app_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:caffinet_app_flutter/features/discover/presentation/pages/discover_page.dart';
import 'package:caffinet_app_flutter/features/discover/domain/usecases/get_optimal_route_usecase.dart';

class MainPage extends StatefulWidget {
  final int userId;

  const MainPage({
    super.key,
    required this.userId,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PersistentTabController _controller;
  String? _selectedCafeteriaId;
  String? _selectedCafeteriaName;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  void _goToSearchTab() {
    setState(() {
      _controller.jumpToTab(1); // pestaña Search
    });
  }

  void _updateSelectedGuide(String id, String name) {
    setState(() {
      _selectedCafeteriaId = id;
      _selectedCafeteriaName = name;
      _controller.jumpToTab(2); // pestaña Guide
    });
  }

  List<Widget> _buildScreens() {
    // ACCESO LIMPIO A GETIT (sl)
    final getOptimalRouteUseCase = sl<GetOptimalRouteUseCase>();
    final osrmService = sl<OSRMService>();

    return [
      HomePageScreen(
        onGoToSearch: _goToSearchTab,
        onGuideSelected: _updateSelectedGuide,
        userId: widget.userId,
      ), // Index 0

      
      SearchPageScreen(
        onGuideSelected: _updateSelectedGuide,
        userId: widget.userId,
      ), // Index 1

      GuidePage(
        cafeteriaId: _selectedCafeteriaId,
        cafeteriaName: _selectedCafeteriaName,
      ), // Index 2

      // INYECCIÓN DE DEPENDENCIA LIMPIA EN DISCOVERPAGE
      DiscoverPage(
        getOptimalRoute: getOptimalRouteUseCase,
        osrmService: osrmService,
      ), // Index 3

      ProfilePage(usuarioId: widget.userId), // Index 4
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        inactiveIcon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: const Color(0xFF2563EB),
        inactiveColorPrimary: const Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_outlined),
        inactiveIcon: const Icon(Icons.search),
        title: "Search",
        activeColorPrimary: const Color(0xFF2563EB),
        inactiveColorPrimary: const Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.map_outlined),
        inactiveIcon: const Icon(Icons.map),
        title: "Guide",
        activeColorPrimary: const Color(0xFF2563EB),
        inactiveColorPrimary: const Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.star_outline),
        inactiveIcon: const Icon(Icons.star),
        title: "Discover",
        activeColorPrimary: const Color(0xFF2563EB),
        inactiveColorPrimary: const Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline),
        inactiveIcon: const Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: const Color(0xFF2563EB),
        inactiveColorPrimary: const Color(0xFF6B7280),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
