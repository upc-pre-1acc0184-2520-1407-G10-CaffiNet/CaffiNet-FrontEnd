import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/models/favorite_cafe_model.dart';
import '../../data/profile_api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileApiService api;
  final int usuarioId;

  UserModel? user;
  List<FavoriteCafeModel> favoritos = [];

  bool loadingUser = false;
  bool loadingFavoritos = false;
  bool updatingUser = false;

  String? errorMessage;

  ProfileViewModel({
    required this.api,
    required this.usuarioId,
  });

  Future<void> loadUser() async {
    loadingUser = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await api.getUser(usuarioId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loadingUser = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoritos() async {
    loadingFavoritos = true;
    errorMessage = null;
    notifyListeners();

    try {
      favoritos = await api.getFavoritos(usuarioId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loadingFavoritos = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String nombre,
    required String email,
    required String password,
  }) async {
    updatingUser = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await api.updateUser(
        userId: usuarioId,
        nombre: nombre,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      updatingUser = false;
      notifyListeners();
    }
  }
}
