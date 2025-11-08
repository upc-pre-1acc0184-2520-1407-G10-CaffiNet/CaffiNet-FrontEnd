// lib/core/constants/api_constants.dart
class ApiConstants {
  // **Asegúrate de cambiar esto a la URL real de tu backend**
  // Ejemplo para desarrollo local:
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Para emuladores Android
  // static const String baseUrl = 'http://localhost:8000/api/v1'; // Para navegadores web o iOS simulator

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
}