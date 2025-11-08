import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/login_user.dart'; // Asegúrate de que esta importación trae LoginUserUseCase y LoginParams

/// ViewModel que maneja la lógica y el estado de la pantalla de inicio de sesión.
class LoginViewModel extends ChangeNotifier {
  // 💡 Obtención de dependencia del Inyector (Service Locator)
  final LoginUserUseCase _loginUserUseCase = sl<LoginUserUseCase>(); 

  // --- Controladores de Formulario ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- Estado de la UI ---
  bool isPasswordVisible = false;
  bool isLoading = false;
  
  // --- Mensajes de Error de Validación ---
  String? emailError;
  String? passwordError;

  // ------------------------------
  // Métodos de Interacción de la UI
  // ------------------------------

  /// Alterna la visibilidad de la contraseña.
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  /// Intenta iniciar sesión llamando al UseCase del dominio.
  Future<bool> login() async {
    // 1. Validaciones básicas en la UI
    emailError = emailController.text.isEmpty ? 'Correo requerido' : null;
    passwordError = passwordController.text.isEmpty ? 'Contraseña requerida' : null;
    notifyListeners();

    if (emailError != null || passwordError != null) return false;

    // 2. Iniciar carga
    isLoading = true;
    notifyListeners();

    try {
      // 3. Ejecutar el UseCase: CORRECCIÓN AQUÍ
      // Se crea y pasa el objeto LoginParams, resolviendo el error de tipos.
      final params = LoginParams(
        email: emailController.text,
        password: passwordController.text,
      );
      
      final user = await _loginUserUseCase.execute(params);
      
      // Aquí podrías guardar la sesión del usuario 'user' si fuera necesario.
      print("Inicio de sesión exitoso para: ${user.email}");
      
      return true;
    } catch (e) {
      // 4. Manejo de errores 
      passwordError = 'Inicio de sesión fallido: ${e.toString()}';
      return false;
    } finally {
      // 5. Finalizar carga
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}