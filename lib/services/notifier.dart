import 'package:flutter/material.dart';
import '../models/models.dart';

class SessionNotifier extends ChangeNotifier {
  Usuario? _usuarioActual;

  Usuario? get usuarioActual => _usuarioActual;

  bool get estaLogueado => _usuarioActual != null;

  void login(Usuario usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }
}