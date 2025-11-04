import 'package:caffinet_app_flutter/core/api/api_service.dart';
import 'package:caffinet_app_flutter/features/auth/data/repositories/user_repository_impl.dart';
import 'package:caffinet_app_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUserUseCase _loginUserUseCase =
      LoginUserUseCase(UserRepositoryImpl(ApiService()));

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;
  String? emailError;
  String? passwordError;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login() async {
    emailError =
        emailController.text.isEmpty ? 'Correo requerido' : null;
    passwordError =
        passwordController.text.isEmpty ? 'Contraseña requerida' : null;
    notifyListeners();

    if (emailError != null || passwordError != null) return false;

    isLoading = true;
    notifyListeners();

    try {
      await _loginUserUseCase.execute(
        emailController.text,
        passwordController.text,
      );
      return true;
    } catch (e) {
      passwordError = 'Inicio de sesión fallido';
      return false;
    } finally {
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
