// lib/core/usecases/usecase.dart

/// Clase base para todos los UseCases en la aplicación.
/// T: Tipo de dato que devuelve el UseCase (e.g., User, void).
/// P: Tipo de dato de los parámetros de entrada (e.g., LoginParams, NoParams).
abstract class UseCase<T, P> {
  Future<T> execute(P params);
}

/// Clase de utilidad cuando un UseCase no requiere parámetros.
class NoParams {}