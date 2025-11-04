import 'package:caffinet_app_flutter/core/api/api_service.dart';
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/register_user.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterUserUseCase _registerUserUseCase =
      RegisterUserUseCase(UserRepositoryImpl(ApiService()));

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  String? nameError;
  String? emailError;
  String? passwordError;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<bool> register() async {
    nameError = nameController.text.isEmpty ? 'Nombre requerido' : null;
    emailError = emailController.text.isEmpty ? 'Email requerido' : null;
    passwordError =
        passwordController.text.isEmpty ? 'Contraseña requerida' : null;
    notifyListeners();

    if (nameError != null || emailError != null || passwordError != null) {
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _registerUserUseCase.execute(
        nameController.text,
        emailController.text,
        passwordController.text,
      );
      return true;
    } catch (e) {
      passwordError = 'Registro fallido: ${e.toString()}';
      return false;
    } finally {
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
