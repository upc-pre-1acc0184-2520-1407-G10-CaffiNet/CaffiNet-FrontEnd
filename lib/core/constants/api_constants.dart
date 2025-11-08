import 'package:caffinet_app_flutter/core/constants.dart';

class ApiConstants {
  // Las constantes de la clase ahora usan la constante global BASE_URL
  // para construir las URLs completas, pero mantenemos los endpoints.
  static const String baseUrl = BASE_URL;
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
  // Opcional: Si necesitas la URL completa en algún lado
  static const String loginUrl = BASE_URL + loginEndpoint;
  static const String registerUrl = BASE_URL + registerEndpoint;
}