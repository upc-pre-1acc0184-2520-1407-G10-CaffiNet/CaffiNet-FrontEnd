import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart'; 
import '../../domain/usecases/register_user.dart';

/// ViewModel que maneja la lógica y el estado de la pantalla de registro.
class RegisterViewModel extends ChangeNotifier {
  // 💡 Obtención de dependencia del Inyector (Service Locator)
  final RegisterUserUseCase _registerUserUseCase = sl<RegisterUserUseCase>(); 

  // --- Controladores de Formulario ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- Estado de la UI ---
  bool isPasswordVisible = false;
  bool isLoading = false;

  // --- Mensajes de Error de Validación ---
  String? nameError;
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

  /// Intenta registrar un nuevo usuario llamando al UseCase del dominio.
  Future<bool> register() async {
    // 1. Validaciones básicas en la UI
    nameError = nameController.text.isEmpty ? 'Nombre requerido' : null;
    emailError = emailController.text.isEmpty ? 'Email requerido' : null;
    passwordError = passwordController.text.isEmpty ? 'Contraseña requerida' : null;
    notifyListeners();

    if (nameError != null || emailError != null || passwordError != null) {
      return false;
    }

    // 2. Iniciar carga
    isLoading = true;
    notifyListeners();

    try {
      // 3. Ejecutar el UseCase (interacción con el dominio/API)
      final user = await _registerUserUseCase.execute(
        nameController.text,
        emailController.text,
        passwordController.text,
      );
      
      // Aquí podrías manejar la respuesta, como guardar la sesión.
      print("Registro exitoso para el usuario: ${user.name}");

      return true;
    } catch (e) {
      // 4. Manejo de errores (por ejemplo, usuario ya existe o problemas de red)
      // Usamos e.toString() para obtener mensajes específicos de la API si están disponibles.
      passwordError = 'Registro fallido: ${e.toString()}'; 
      return false;
    } finally {
      // 5. Finalizar carga
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}