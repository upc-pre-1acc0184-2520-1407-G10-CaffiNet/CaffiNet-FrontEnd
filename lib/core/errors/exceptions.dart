
/// Excepción base para errores relacionados con el servidor (ej: 404, 500).
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Excepción específica para errores de Autenticación (ej: 401 Unauthorized, credenciales inválidas).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

/// Excepción genérica de caché para cuando los datos locales fallan.
class CacheException implements Exception {}