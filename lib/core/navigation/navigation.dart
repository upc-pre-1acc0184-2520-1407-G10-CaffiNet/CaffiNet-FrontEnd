import 'package:caffinet_app_flutter/core/widgets/main_navbar.dart';
import 'package:caffinet_app_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:caffinet_app_flutter/features/auth/presentation/pages/register_screen.dart';
import 'package:caffinet_app_flutter/features/search/presentation/pages/search_page_screen.dart';
import 'package:flutter/material.dart';

class AppNavigation {
  /// Genera las rutas dinámicamente según el nombre.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/home':
        //  leemos el userId que viene desde el login
        final userId = settings.arguments as int?;

        // Si por alguna razón viene null, mandamos al login
        if (userId == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        // Pasamos el userId a MainPage
        return MaterialPageRoute(
          builder: (_) => MainPage(userId: userId),
        );

      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchPageScreen());

      case '/guide':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Guide Page')),
          ),
        );

      case '/discover':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Discover Page')),
          ),
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Profile Page')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
