import 'package:caffinet_app_flutter/features/home/presentation/pages/homePage_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return const [
      HomePageScreen(),
      Scaffold(body: Center(child: Text('Search Page'))),
      Scaffold(body: Center(child: Text('Guide Page'))),
      Scaffold(body: Center(child: Text('Discover Page'))),
      Scaffold(body: Center(child: Text('Profile Page'))),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        inactiveIcon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Color(0xFF2563EB),
        inactiveColorPrimary: Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_outlined),
        inactiveIcon: const Icon(Icons.search),
        title: "Search",
        activeColorPrimary: Color(0xFF2563EB),
        inactiveColorPrimary: Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.map_outlined),
        inactiveIcon: const Icon(Icons.map),
        title: "Guide",
        activeColorPrimary: Color(0xFF2563EB),
        inactiveColorPrimary: Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.star_outline),
        inactiveIcon: const Icon(Icons.star),
        title: "Discover",
        activeColorPrimary: Color(0xFF2563EB),
        inactiveColorPrimary: Color(0xFF6B7280),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline),
        inactiveIcon: const Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Color(0xFF2563EB),
        inactiveColorPrimary: Color(0xFF6B7280),
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