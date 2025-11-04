import 'package:caffinet_app_flutter/core/navigation/navigation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      initialRoute: '/login', 
      onGenerateRoute: AppNavigation.generateRoute,
    );
  }
}