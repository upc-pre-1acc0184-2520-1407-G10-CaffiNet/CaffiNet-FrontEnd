import 'package:caffinet_app_flutter/features/guide/presentation/pages/guide_page.dart';
import 'package:caffinet_app_flutter/features/home/presentation/pages/homePage_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:caffinet_app_flutter/features/search/presentation/pages/search_page_screen.dart';
import 'package:caffinet_app_flutter/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  //  id del usuario logeado
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
      // 1 es el índice de la pestaña Search
      _controller.jumpToTab(1); 
    });
  }
  // 2. FUNCIÓN DE ACTUALIZACIÓN DE ESTADO Y NAVEGACIÓN
  void _updateSelectedGuide(String id, String name) {
    // 1. Actualizar el estado (esto reconstruye GuidePage con los datos)
    setState(() {
      _selectedCafeteriaId = id;
      _selectedCafeteriaName = name;
      _controller.jumpToTab(2);
    });

  }

  

  List<Widget> _buildScreens() {
    //  ya no puede ser `const [` porque usamos widget.userId
    return [
      HomePageScreen(
            onGoToSearch: _goToSearchTab,
            onGuideSelected: _updateSelectedGuide 
      ),

      SearchPageScreen(onGuideSelected: _updateSelectedGuide),
      
      GuidePage(
        cafeteriaId: _selectedCafeteriaId, 
        cafeteriaName: _selectedCafeteriaName,
      ),  
      const Scaffold(body: Center(child: Text('Discover Page'))),

      ProfilePage(usuarioId: widget.userId), // usa el id del usuario logeado
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
