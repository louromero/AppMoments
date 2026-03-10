import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/database.dart';
import '../services/notifier.dart';

class UnirseAlbumPage extends StatefulWidget {
  const UnirseAlbumPage({super.key});

  @override
  State<UnirseAlbumPage> createState() => _UnirseAlbumPageState();
}

class _UnirseAlbumPageState extends State<UnirseAlbumPage> {
  final _tituloController = TextEditingController();
  final _claveController = TextEditingController();
  
  
  bool _isLoading = false;

  @override
  void dispose() {
    
    _tituloController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _unirse() async {
    final titulo = _tituloController.text.trim();
    final clave = _claveController.text.trim();

    // 1. Validación básica de campos
    if (titulo.isEmpty || clave.isEmpty) {
      _mostrarSnackBar("Por favor, completa todos los campos");
      return;
    }

    final session = Provider.of<SessionNotifier>(context, listen: false);
    final usuario = session.usuarioActual;

    if (usuario == null || usuario.id == null) {
      _mostrarSnackBar("Error: No se encontró la sesión del usuario");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Intento de unión en la base de datos
      final ok = await MomentoDatabase.instance.unirseAlbum(
        titulo,
        clave,
        usuario.id!,
      );

      if (!mounted) return;

      if (ok) {
        _mostrarSnackBar("¡Te has unido al álbum con éxito!");
        // Volver a la pantalla anterior después de un breve delay para que vean el mensaje
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _mostrarSnackBar("Álbum no encontrado o clave incorrecta");
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar("Error al intentar unirse: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mismo color de AppBar que en Perfil y Configuración
      appBar: AppBar(
        title: const Text(
          "Unirse a Álbum",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 242, 221),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      
      backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(
              Icons.group_add_outlined,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "¿Recibiste una clave?\nIngresa los datos para participar en el álbum.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // TextField de Título
            _buildTextField(
              controller: _tituloController,
              hint: 'Título del Álbum',
              icon: Icons.book,
            ),

            const SizedBox(height: 20),

            // TextField de Clave
            _buildTextField(
              controller: _claveController,
              hint: 'Clave de acceso',
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 40),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _unirse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "UNIRSE AL ÁLBUM",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para mantener el diseño limpio y uniforme
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: Colors.orange),
        ),
      ),
    );
  }
}