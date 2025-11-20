import 'package:flutter/material.dart';

import '../../data/profile_api_service.dart';
import '../../data/models/user_model.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/favorite_cafe_card.dart';

class ProfilePage extends StatefulWidget {
  final int usuarioId; 

  const ProfilePage({
    Key? key,
    required this.usuarioId,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _viewModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      api: ProfileApiService(),
      usuarioId: widget.usuarioId,
    );

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });

    _viewModel.loadUser();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _mostrarSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _abrirFavoritosSheet() async {
    await _viewModel.loadFavoritos();

    if (_viewModel.errorMessage != null) {
      _mostrarSnackBar('Error al cargar favoritos');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F1FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (_viewModel.favoritos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 8),
                Text(
                  'No tienes cafeterías en favoritos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        }

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Tus favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: _viewModel.favoritos.length,
                      itemBuilder: (context, index) {
                        final fav = _viewModel.favoritos[index];
                        return FavoriteCafeCard(fav: fav);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

 
  void _logout() async {
    await _viewModel.loadUser(); 
    if (mounted) {
      _mostrarSnackBar('Perfil recargado');
    }
  }

  Future<void> _mostrarDialogEditarPerfil() async {
    final UserModel? user = _viewModel.user;
    if (user == null) return;

    final nombreCtrl = TextEditingController(text: user.nombre);
    final emailCtrl = TextEditingController(text: user.email);
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: _viewModel.updatingUser
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
              onPressed: _viewModel.updatingUser
                  ? null
                  : () async {
                      final nuevoNombre = nombreCtrl.text.trim();
                      final nuevoEmail = emailCtrl.text.trim();
                      final nuevoPassword = passwordCtrl.text.trim();

                      if (nuevoNombre.isEmpty ||
                          nuevoEmail.isEmpty ||
                          nuevoPassword.isEmpty) {
                        _mostrarSnackBar(
                            'Nombre, email y password no pueden estar vacíos');
                        return;
                      }

                      final ok = await _viewModel.updateUser(
                        nombre: nuevoNombre,
                        email: nuevoEmail,
                        password: nuevoPassword,
                      );

                      if (!mounted) return;

                      if (ok) {
                        Navigator.of(ctx).pop();
                        _mostrarSnackBar('Perfil actualizado correctamente');
                      } else {
                        _mostrarSnackBar('Error al actualizar perfil');
                      }
                    },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const fondo = Color(0xFFFDF5FF);

    final nombreParaMostrar = _viewModel.user?.nombre ?? 'Usuario';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: TextButton(
                        onPressed: _viewModel.loadingFavoritos
                            ? null
                            : _abrirFavoritosSheet,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFB487FF)),
                          ),
                        ),
                        child: _viewModel.loadingFavoritos
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Favoritos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

             
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFE0C8FF),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              
              Center(
                child: Column(
                  children: [
                    Text(
                      _viewModel.loadingUser
                          ? 'Cargando usuario...'
                          : 'Bienvenido,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!_viewModel.loadingUser)
                      Text(
                        nombreParaMostrar,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (_viewModel.user != null)
                Center(
                  child: Text(
                    _viewModel.user!.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

              const SizedBox(height: 36),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      onPressed: _viewModel.loadingUser
                          ? null
                          : _mostrarDialogEditarPerfil,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      child: const Text(
                        'Editar perfil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Gestiona tu cuenta y tus cafeterías favoritas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
