import 'package:caffinet_app_flutter/core/navigation/navigation.dart';
import 'package:flutter/material.dart';

// Importa la función de inicialización del inyector
import 'core/di/injector.dart' as di; 

void main() {
  // 1. Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Llama a la inicialización del inyector
  // Esto registra todas las clases (UseCases, Repositorios, DataSources) en GetIt.
  di.init(); 

  // 3. Inicia la aplicación
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