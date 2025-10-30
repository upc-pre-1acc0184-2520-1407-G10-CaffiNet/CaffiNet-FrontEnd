import 'package:caffinet_app_flutter/presentation/view/iam/home_screen.dart';
import 'package:caffinet_app_flutter/presentation/viewmodel/iam/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Registro')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  TextField(
                    controller: vm.nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      errorText: vm.nameError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email
                  TextField(
                    controller: vm.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: vm.emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contraseña
                  TextField(
                    controller: vm.passwordController,
                    obscureText: !vm.isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      errorText: vm.passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón Registrar
                  ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vm.register();
                            if (success && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MainPage()),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Crear Cuenta'),
                  ),
                  const SizedBox(height: 16),
                  // Link a Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Ya tengo cuenta, Iniciar sesión'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
